#!/bin/bash


# Error handling
function error()
{
	echo -e "[ `date` ] $(tput setaf 1)$@$(tput sgr0)"
	exit $2
}

# Unhide Startup
sed -i "s/NoDisplay=true/NoDisplay=false/g" /etc/xdg/autostart/*.desktop

# Execute: apt-get update
apt-get update \
|| error "Unable to execute apt-get update command, exit status = " $?

# Google Repository
echo "Adding google-chrome repository, please wait..."
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - \
&& sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list' \
|| ee_lib_error "Unable to add google-chrome repository, exit status = " $?

# Shutter Repository
echo "Adding shutter repository, please wait..."
sudo add-apt-repository -y ppa:shutter/ppa \
|| ee_lib_error "Unable to add shutter repository, exit status = " $?

# Hipchat
echo "deb http://downloads.hipchat.com/linux/apt stable main" > \
  /etc/apt/sources.list.d/atlassian-hipchat.list && \
  wget -O - https://www.hipchat.com/keys/hipchat-linux.key | apt-key add - \
  || ee_lib_error "Unable to add Hipchat repository, exit status = " $?

# Execute: apt-get update
apt-get update \
|| error "Unable to execute apt-get update command, exit status = " $?

# Install required packages
echo "Installing necessary packages, please wait..."
apt-get -y install git-core openssh-server shutter google-chrome-stable vlc hipchat openjdk-8-jre openjdk-8-jdk gparted diodon nautilus-open-terminal \
|| error "Unable to install required packages, exit status = " $?
