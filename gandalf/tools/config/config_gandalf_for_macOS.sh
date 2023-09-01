#!/bin/bash
# Install XCode
sudo rm -rf /Library/Developer/CommandLineTools
xcode-select --install

# Install PowerShell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install --cask powershell

# Install WSMan
pwsh -Command 'Install-Module -Name PSWSMan -Force'
sudo pwsh -Command 'Install-WSMan'