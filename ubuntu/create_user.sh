#!/usr/bin/env bash

set -x

if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script from your root account"
  exit 1
fi


PASSWORD=P@ssw0rd
if [ $# -eq 2 ]; then
    PASSWORD=$2
fi

if [ $# -eq 1 ] || [ $# -eq 2 ]; then
    groupadd "$1"
    useradd -m -g "$1" "$1"
    echo "$1:$PASSWORD" | chpasswd
    usermod -aG sudo "$1"
else
  echo "Please run this script with one or two params"
  echo "create_user.sh user password"
  echo "or"
  echo "create_user.sh user  # for default password"
fi

