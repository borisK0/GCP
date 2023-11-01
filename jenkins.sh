#!/bin/bash

# Update system packages
sudo apt update

# Install dependencies
sudo apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common openjdk-11-jdk

# Securely add the Jenkins GPG key to a specific keyring
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# Add the Jenkins repository using the specific keyring
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update system packages again to include the Jenkins repository
sudo apt update

# Check if Jenkins repository is trusted and available
if apt-cache policy jenkins | grep https://pkg.jenkins.io/debian-stable; then
    # Install Jenkins
    sudo apt install jenkins -y
    
    # Start and enable Jenkins service
    sudo systemctl start jenkins
    sudo systemctl enable jenkins

    # Output initial admin password for Jenkins setup
    echo "Initial Jenkins Admin Password:"
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    echo ""
else
    echo "Jenkins repository seems not trusted or unavailable. Exiting."
    exit 1
fi

