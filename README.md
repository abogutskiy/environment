# About

This repo contains scripts and config to quickly configure personal laptop and
linux vm's. Scripts create system resource, install all necessary software, copy
configs, create users and run needed services.

Basic setup consists of several steps:
 * create sudoer user `TODO: create and switch to user in setup_base script`
 * setup_base.sh – swithce shell, create needed users, folders, etc. install all
                   required software
 * clone this git repo
 * setup_configs.sh – setup all needed configs for zsh, vim, tmux, git, etc
 * (optional but recommended) add .ssh config, github private key, add pub
   key to authorized key


# Ubuntu

How to setup:
```
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/abogutskiy/environment/main/ubuntu/create_user.sh)" -- $newuser $password \
  && su $newuser
   curl -fsSL https://raw.githubusercontent.com/abogutskiy/environment/main/ubuntu/setup_base.sh | bash
   ~/environment/ubuntu/setup_configs.sh
   # prepare ssh config, github priv key, add pub key to authorized_keys
```


Install common dev-machine tools and libs including:
* neovim
* tmux
* git
* curl/wget/telnet
* openssl
* ca-certificates
* docker
* and other

# MacOs

`TODO add support`
