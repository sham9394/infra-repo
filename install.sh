#!/bin/bash
# ============================================================
# Ultra-Fast Installer: Ansible + Jenkins + Java 21 (Ubuntu)
# ============================================================

set -e  # Exit on error

print_msg() {
  echo -e "\n\033[1;32m$1\033[0m\n"
}

print_msg "🔹 Updating package index (single update)..."
sudo apt-get update -y

print_msg "🔹 Installing dependencies + Java 21..."
sudo apt-get install -y \
    software-properties-common \
    curl \
    openjdk-21-jdk

print_msg "🔹 Adding Ansible PPA..."
sudo add-apt-repository --yes ppa:ansible/ansible

print_msg "🔹 Adding Jenkins repository key..."
sudo mkdir -p /usr/share/keyrings
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key \
  | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

print_msg "🔹 Adding Jenkins apt repository..."
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ \
  | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

print_msg "🔹 Updating package index (final update)..."
sudo apt-get update -y

print_msg "🔹 Installing Ansible + Jenkins..."
sudo apt-get install -y ansible jenkins

print_msg "🔹 Starting & enabling Jenkins..."
sudo systemctl enable jenkins
sudo systemctl start jenkins

print_msg "🔹 Verifying installations..."

echo "----------------------------"
ansible --version | head -n 1
echo "----------------------------"
java -version
echo "----------------------------"
systemctl status jenkins | grep Active
echo "----------------------------"

print_msg "🔑 Initial Jenkins Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo -e "\n🌐 Access Jenkins at: http://<your-server-ip>:8080\n"
