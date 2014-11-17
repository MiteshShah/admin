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

# Skype Repository 
echo "Adding skype repository, please wait..."
sudo sh -c  'echo "deb http://archive.canonical.com/ubuntu/ $(lsb_release -sc) partner" >> /etc/apt/sources.list.d/canonical_partner.list' \
|| ee_lib_error "Unable to add skype repository, exit status = " $?

# Shutter Repository
echo "Adding shutter repository, please wait..."
sudo add-apt-repository -y ppa:shutter/ppa \
|| ee_lib_error "Unable to add shutter repository, exit status = " $?


# Execute: apt-get update
apt-get update \
|| error "Unable to execute apt-get update command, exit status = " $?

# Install required packages
echo "Installing necessary packages, please wait..."
apt-get -y install git-core openssh-server shutter filezilla google-chrome-stable skype sni-qt sni-qt:i386 openjdk-8-jre icedtea-8-plugin openjdk-8-jdk diodon diodon-plugins ubuntu-restricted-extras nautilus-open-terminal \
|| error "Unable to install required packages, exit status = " $?
