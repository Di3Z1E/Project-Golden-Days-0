#!/bin/bash

# Set Variables
export USER=$(whoami)
export HOME=$(eval echo ~$USER)

# Elevate the script to run as root if not already
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Update and Upgrade the local server
apt update && apt upgrade -y

# Uninstall all conflicting packages
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do apt-get remove -y $pkg; done

# Install Ansible
apt install -y software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt install -y ansible

# Install anisble items
ansible-playbook src/ansible/00_setup.yml -vvv

# Convert dox to unix
dos2unix /samp/samp-setup.sh

# Set folders
mkdir ${HOME}/golden_days_2000
mkdir ${HOME}/golden_days_2000/game_servers

mkdir ${HOME}/golden_days_2000/game_servers/samp

mkdir ${HOME}/golden_days_2000/game_servers/cs

# Download game servers
docker pull krustowski/samp-server-docker
docker pull cs16ds/server:latest
docker pull left4devops/l4d
