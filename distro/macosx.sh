#!/bin/bash

echo "Installing HomeBrew, please wait..."
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo "Installing HomeBrew Cask, please wait..."
brew install caskroom/cask/brew-cask

echo "Installing Google Chrome, please wait..."
brew cask install google-chrome
brew cask install 1password

echo "Installing Oh-My-ZSH, please wait..."
curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
