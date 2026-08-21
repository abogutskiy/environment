#!/usr/bin/env bash
#
# Debian variant of setup_base.sh, tested against Debian 13 (trixie) running in
# a slim container image. Differences from the Ubuntu script are all forced by
# real breakage, each marked "DEBIAN FIX" below.

if [ "$(id -u)" -eq 0 ]; then
  echo "Please run this script from your sudoer user account"
  exit 1
fi

set -euxo pipefail

# Avoid interactive prompts from apt/needrestart that can stall the script
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

. /etc/os-release
if [ "${ID:-}" != "debian" ]; then
  echo "This is the Debian script; on Ubuntu use setup_base.sh instead (ID=${ID:-unknown})"
  exit 1
fi
CODENAME="${VERSION_CODENAME:?cannot determine Debian codename}"

# Some slim images ship no systemd (this one runs s6-svscan as PID 1), so
# systemctl is permanently "offline" and every `systemctl` call fails.
has_systemd() { [ -d /run/systemd/system ]; }

# create all necessary files/folders
mkdir -p ~/.ssh
chmod 700 ~/.ssh
sudo chown $USER:$USER ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
echo "Don't forget add public/private keys pairs if needed"
echo "Don't forget to add your personal public key to authorized_keys if needed"

sudo -E apt update

# DEBIAN FIX 1: repair gutted dpkg metadata before installing anything.
#
# The slim image ships ~250 packages marked "ii" whose control files were
# stripped from /var/lib/dpkg/info. Mostly that only breaks `dpkg -L` / `dpkg -S`,
# but for `ucf` it is fatal: /usr/bin/ucf resolves its debconf templates at
# runtime via
#     db_x_loadtemplatefile "$(dpkg-query --control-path ucf templates)" ucf
# which expands to an empty path, so debconf answers
#     --> 10 failed to open ucf: No such file or directory
# and every postinst that calls ucf dies with "subprocess returned error exit
# status 10". postgresql-common and sysstat both call ucf, and postgresql-17 /
# postgresql then fail as dependency fallout. Repairing this first is what makes
# the install below succeed.
repair_dpkg_metadata() {
  local needs p a m s f
  needs=""

  while read -r p a m s; do
    if [ "$m" = "same" ]; then
      f="/var/lib/dpkg/info/$p:$a.list"
    else
      f="/var/lib/dpkg/info/$p.list"
    fi
    if [ ! -f "$f" ]; then
      if [ "$m" = "same" ]; then
        needs="$needs $p:$a"
      else
        needs="$needs $p"
      fi
    fi
  done < <(dpkg-query -W -f='${Package} ${Architecture} ${Multi-Arch} ${db:Status-Abbrev}\n' 2>/dev/null | awk '$4=="ii"')

  # ucf can also be half-registered: .list present but .templates missing. Check
  # it the same way ucf itself does, since it is the load-bearing case.
  if dpkg-query -W ucf >/dev/null 2>&1; then
    if [ ! -s "$(dpkg-query --control-path ucf templates 2>/dev/null || true)" ]; then
      needs="$needs ucf"
    fi
  fi

  if [ -z "${needs// /}" ]; then
    echo "dpkg metadata intact, nothing to repair"
    return 0
  fi

  echo "Repairing dpkg metadata for:$needs"
  # --force-confold/--force-confdef so reinstalling never clobbers local edits
  # to config files that are already on disk.
  sudo -E apt-get install --reinstall -y \
    -o Dpkg::Options::=--force-confold \
    -o Dpkg::Options::=--force-confdef \
    $needs
}
repair_dpkg_metadata

# install basic needed software and libs
# install before upgrade so a stalled/failed upgrade doesn't skip the install
#
# DEBIAN FIX 2: two packages from the Ubuntu list are gone here.
#   - software-properties-common does not exist in trixie at all (the
#     software-properties source is in bookworm and in sid, but was dropped
#     before the trixie release), so naming it makes apt abort without
#     installing *anything* else in the same command. Its `add-apt-repository`
#     has no replacement; write deb822 .sources files by hand instead, the way
#     the Docker step below does.
#   - apt-transport-https has been a transitional dummy package since apt 1.5;
#     https support is built into apt now.
sudo -E apt install -y \
    zsh \
    git \
    git-crypt \
    vim \
    curl \
    wget \
    gnupg \
    openssl \
    pass \
    python3 \
    python3-pip \
    python3-venv \
    telnet \
    tmux \
    htop \
    ca-certificates \
    locales \
    postgresql
sudo -E apt upgrade -y

# DEBIAN FIX 3: generate the UTF-8 locale. The slim image sets LANG/LC_ALL to
# en_US.UTF-8 but excludes /usr/share/locale/* at unpack time, so nothing has
# actually been generated and every perl/bash invocation prints
#     perl: warning: Setting locale failed. ... Falling back to the standard locale ("C").
# which buries real output (pg_lsclusters is especially noisy).
if ! locale -a 2>/dev/null | grep -qiE '^en_US\.?(utf-?8)$'; then
    sudo sed -i 's/^# *\(en_US\.UTF-8 UTF-8\)/\1/' /etc/locale.gen
    sudo locale-gen
    sudo update-locale LANG=en_US.UTF-8
fi

sudo usermod -s $(which zsh) $USER

# DEBIAN FIX 4: postgresql's postinst cannot start the cluster, because the slim
# image installs /usr/sbin/policy-rc.d returning 101 ("deny all service
# starts"), which logs:
#     invoke-rc.d: policy-rc.d denied execution of start.
# initdb still ran, so the cluster exists but sits at Status=down. Bring it up
# via pg_ctlcluster, which works with or without systemd.
if ! pg_lsclusters -h | awk '{print $4}' | grep -q online; then
    PG_VER=$(pg_lsclusters -h | awk 'NR==1{print $1}')
    PG_CLUSTER=$(pg_lsclusters -h | awk 'NR==1{print $2}')
    sudo pg_ctlcluster "$PG_VER" "$PG_CLUSTER" start || \
        echo "WARNING: could not start postgres cluster $PG_VER/$PG_CLUSTER; check /var/log/postgresql/"
fi

# DEBIAN FIX 5: install neovim from the upstream tarball rather than snap.
# `snap install --classic nvim` cannot work here: snapd is not installed, and
# snapd requires systemd, which this image does not run. Debian trixie's apt
# neovim is 0.10.4 (not the ancient 0.7.x the Ubuntu comment warns about) so apt
# would be acceptable, but the tarball keeps parity with snap's newer stream.
if command -v nvim >/dev/null 2>&1; then
    echo "nvim already installed, skipping"
else
    case "$(dpkg --print-architecture)" in
        amd64) NVIM_ARCH="linux-x86_64" ;;
        arm64) NVIM_ARCH="linux-arm64" ;;
        *) echo "unsupported arch for nvim tarball: $(dpkg --print-architecture)"; exit 1 ;;
    esac
    NVIM_TMP=$(mktemp -d)
    curl -fsSL -o "$NVIM_TMP/nvim.tar.gz" \
        "https://github.com/neovim/neovim/releases/latest/download/nvim-${NVIM_ARCH}.tar.gz"
    sudo rm -rf "/opt/nvim-${NVIM_ARCH}"
    sudo tar -C /opt -xzf "$NVIM_TMP/nvim.tar.gz"
    sudo ln -sfn "/opt/nvim-${NVIM_ARCH}/bin/nvim" /usr/local/bin/nvim
    rm -rf "$NVIM_TMP"
fi

# install claude cli (skip if already installed)
if command -v claude >/dev/null 2>&1 || [ -x "$HOME/.local/bin/claude" ]; then
    echo "claude already installed, skipping"
else
    curl -fsSL https://claude.ai/install.sh | bash
fi

# install docker (skip if already installed)
#
# DEBIAN FIX 6: the Ubuntu script points at download.docker.com/linux/ubuntu and
# derives the suite with `lsb_release -cs`. Both are wrong here: the Ubuntu repo
# has no trixie suite, and lsb_release is not installed on the slim image (so the
# old line would have expanded to an empty suite). Use the debian repo and read
# the codename from /etc/os-release.
if command -v dockerd >/dev/null 2>&1; then
    echo "docker daemon already installed, skipping"
elif command -v docker >/dev/null 2>&1 && [ -n "${DOCKER_HOST:-}" ]; then
    # This image ships static docker/buildx/compose binaries in /usr/local/bin
    # (not dpkg packages) and points DOCKER_HOST at a daemon over TCP. Installing
    # docker-ce on top would add a second, unused local daemon.
    echo "docker CLI present, DOCKER_HOST=$DOCKER_HOST -> using remote daemon, skipping install"
elif command -v docker >/dev/null 2>&1; then
    echo "docker CLI present but no dockerd and no DOCKER_HOST; skipping install"
    echo "  (set DOCKER_HOST, or remove $(command -v docker) to install docker-ce here)"
else
    sudo install -m 0755 -d /usr/share/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg \
        | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    sudo chmod a+r /usr/share/keyrings/docker-archive-keyring.gpg
    # deb822 format, matching how this image already writes /etc/apt/sources.list.d
    sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: ${CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /usr/share/keyrings/docker-archive-keyring.gpg
EOF
    sudo -E apt-get update
    sudo -E apt-get -y install docker-ce docker-ce-cli containerd.io
fi

# DEBIAN FIX 7: `usermod -aG docker $USER` aborts the whole script here with
#     usermod: group 'docker' does not exist
# The docker group only exists to grant access to a local unix socket, and it is
# created by the docker-ce package's postinst. This image has no docker-ce, no
# /var/run/docker.sock, and reaches its daemon over tcp://, where group
# membership is irrelevant. So only touch the group when it is actually useful.
if getent group docker >/dev/null 2>&1; then
    sudo usermod -aG docker $USER
elif [ -S /var/run/docker.sock ]; then
    sudo groupadd -f docker
    sudo usermod -aG docker $USER
else
    echo "no docker group and no local /var/run/docker.sock; skipping group membership"
    echo "  (access to ${DOCKER_HOST:-the daemon} does not depend on the docker group)"
fi

# DEBIAN FIX 8: `systemctl enable docker` fails outright without systemd
# (systemctl reports "offline"). Only try it when systemd is actually the init.
if has_systemd && command -v dockerd >/dev/null 2>&1; then
    sudo systemctl enable docker
else
    echo "no systemd (PID 1 is $(ps -p 1 -o comm=)) or no local dockerd; skipping 'systemctl enable docker'"
    if [ -n "${DOCKER_HOST:-}" ]; then
        echo "  (DOCKER_HOST=$DOCKER_HOST is already serving this client; nothing to enable)"
    else
        echo "  (start a daemon manually with: sudo dockerd &   -- or run this host under systemd)"
    fi
fi

if [ ! -d ~/environment ]; then
    git clone https://github.com/abogutskiy/environment.git ~/environment
fi
