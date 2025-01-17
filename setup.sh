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
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
  apt-get remove -y $pkg
done

# Install Ansible
apt install -y software-properties-common
add-apt-repository --yes --update ppa:ansible/ansible
apt install -y ansible

# Install ansible items
ansible-playbook ${HOME}/Project-Golden-Days-2000/src/ansible/00_setup.yml -vvv || { echo "Ansible playbook failed"; exit 1; }

# Convert dos to unix
dos2unix ${HOME}/Project-Golden-Days-2000/src/samp/samp-setup.sh || { echo "Failed to convert line endings"; exit 1; }

# Set folders
mkdir -p ${HOME}/golden_days_2000/game_servers/samp
mkdir -p ${HOME}/golden_days_2000/game_servers/cs

# Download game servers
docker pull krustowski/samp-server-docker
docker pull cs16ds/server:latest
docker pull left4devops/l4d

# Start all servers
docker compose -f ${HOME}/Project-Golden-Days-2000/src/all-game-servers/docker-compose.yml up -d || { echo "Docker Compose failed"; exit 1; }

# Run additional setup script
bash ${HOME}/Project-Golden-Days-2000/src/samp/samp-setup.sh || { echo "samp-setup.sh failed"; exit 1; }
