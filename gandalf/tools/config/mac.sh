# required for https://pypi.org/project/pyminizip/
#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
sleep 1
sudo rm -rf /Library/Developer/CommandLineTools
xcode-select --install
sleep 1
brew install zlib