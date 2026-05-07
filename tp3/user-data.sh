#!/bin/bash
# Installation Docker
sudo apt remove -y docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc || true
# Ajouter la clé GPG Docker officielle:
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Ajouter le dépôt aux sources de apt:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
# Mise à jour de la BD locales des paquets et installation
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Variables
REPO_URL="https://github.com/Milleboy2007/tp3-2484435.git"
DEST_DIR="/home/ubuntu/tp3-2484435"
OS_USER="ubuntu"

# Installation de git
sudo apt install git -y

# Clonage
sudo -u $OS_USER git clone "$REPO_URL" "$DEST_DIR"

# Créer une copie du .env.exemple
sudo -u $OS_USER cp "$DEST_DIR/.env.exemple" "$DEST_DIR/.env"

sudo docker compose -f "$DEST_DIR/compose.yaml" up -d