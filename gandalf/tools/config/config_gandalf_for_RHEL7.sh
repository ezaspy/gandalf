#!/bin/bash
# Register the Microsoft RedHat repository
curl https://packages.microsoft.com/config/rhel/7/prod.repo | sudo tee /etc/yum.repos.d/microsoft.repo

# Install PowerShell
sudo dnf install --assumeyes powershell

# Install WSMan
pwsh -Command 'Install-Module -Name PSWSMan -Force'
sudo pwsh -Command 'Install-WSMan'