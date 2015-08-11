#!/bin/bash
# Toogle Show/Hide Hidden Files
# Author : Mr.Miteshah@gmail.com

# Check Status
STATUS=`defaults read com.apple.finder AppleShowAllFiles` 
if [ $STATUS == 1 ] 
	then 
		defaults write com.apple.finder AppleShowAllFiles -boolean false
	else 
		defaults write com.apple.finder AppleShowAllFiles -boolean true
fi

# Kill Finder Application
killall Finder
