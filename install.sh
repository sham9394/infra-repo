#!/bin/bash
# Simple script to install Ansible on Ubuntu
# Usage: ./install-ansible.sh

set -e

echo "🔹 Updating system packages..."
sudo apt update -y
sudo apt upgrade -y

echo "🔹 Installing required dependencies..."
sudo apt install -y software-properties-common

echo "🔹 Adding official Ansible PPA..."
sudo add-apt-repository --yes --update ppa:ansible/ansible

echo "🔹 Installing Ansible..."
sudo apt install -y ansible

echo "🔹 Verifying installation..."
ansible --version

echo "✅ Ansible installation completed successfully!"

#!/bin/bash
# ============================================================
# Jenkins Installation Script for Ubuntu (Debian-based systems)
# Installs Jenkins with Java 21
# ============================================================

set -e  # Exit immediately if any command fails

# Function to display colored output
print_msg() {
  echo -e "\n\033[1;32m$1\033[0m\n"
}

print_msg "🔹 Updating system packages..."
sudo apt update -y

print_msg "🔹 Installing Java 21 (OpenJDK)..."
sudo apt install -y openjdk-21-jdk

print_msg "✅ Java installed successfully:"
java -version

print_msg "🔹 Adding Jenkins repository key..."
sudo mkdir -p /usr/share/keyrings
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | \
  sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

print_msg "🔹 Adding Jenkins apt repository..."
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

print_msg "🔹 Updating package list..."
sudo apt update -y

print_msg "🔹 Installing Jenkins..."
sudo apt install -y jenkins

print_msg "🔹 Enabling and starting Jenkins service..."
sudo systemctl enable jenkins
sudo systemctl start jenkins

print_msg "✅ Jenkins installation complete!"
echo "------------------------------------------------------------"
sudo systemctl status jenkins | grep Active
echo "------------------------------------------------------------"
print_msg "🔑 Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "------------------------------------------------------------"
echo "🌐 Access Jenkins at: http://<your-server-ip>:8080"
echo "------------------------------------------------------------"
