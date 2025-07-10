#!/bin/bash

# Docker Installation Script for Debian/Ubuntu
# Run with: bash install-docker.sh

set -e

echo "🐳 Installing Docker on Debian/Ubuntu..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root"
   exit 1
fi

# Update system packages
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install prerequisites
print_status "Installing prerequisites..."
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
print_status "Adding Docker GPG key..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the repository
print_status "Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update apt package index
print_status "Updating package index..."
sudo apt update

# Install Docker Engine
print_status "Installing Docker Engine..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add current user to docker group
print_status "Adding user to docker group..."
sudo usermod -aG docker $USER

# Enable and start Docker service
print_status "Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Test Docker installation
print_status "Testing Docker installation..."
if sudo docker run hello-world > /dev/null 2>&1; then
    print_status "Docker installation successful!"
else
    print_error "Docker installation test failed"
    exit 1
fi

# Install docker-compose (standalone) as backup
print_status "Installing docker-compose (standalone)..."
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d'"' -f4)
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installations
print_status "Verifying installations..."
echo "Docker version:"
sudo docker --version
echo ""
echo "Docker Compose (plugin) version:"
sudo docker compose version
echo ""
echo "Docker Compose (standalone) version:"
docker-compose --version

print_warning "Please log out and log back in (or run 'newgrp docker') to use Docker without sudo"
print_status "Installation complete! 🎉"

# Optional: Install additional useful tools
read -p "Install additional tools (htop, git, curl, wget)? [y/N]: " -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Installing additional tools..."
    sudo apt install -y htop git curl wget vim nano
fi

print_status "Setup complete! You can now run your Docker server."
echo ""
echo "Next steps:"
echo "1. Log out and back in (or run 'newgrp docker')"
echo "2. Navigate to your docker-server directory"
echo "3. Customize .env and docker-compose.yml"
echo "4. Run: docker-compose up -d"
