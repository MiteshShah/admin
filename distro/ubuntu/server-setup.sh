#!/bin/bash

# Error handling
function error()
{
	echo -e "[ `date` ] $(tput setaf 1)$@$(tput sgr0)"
	exit $2
}

# Install required packages
apt-get -y install clamav fail2ban inotify-tools mailutils \
|| error "Unable to install required packages, exit status = " $?

# Update ClamAV Database
freshclam \
|| error "Unable to execute freshclam, exit status = " $?


