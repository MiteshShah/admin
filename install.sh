#!/bin/bash

# Error handling
function error()
{
	echo -e "[ `date` ] $(tput setaf 1)$@$(tput sgr0)"
	exit $2
}

# Execute: apt-get update
apt-get update \
|| error "Unable to execute apt-get update command, exit status = " $?

# Install required packages
apt-get -y install python-software-properties software-properties-common sudo vim screen pv htop curl wget \
|| error "Unable to install required packages, exit status = " $?


# Custom Prompt PS1
cp -av /etc/skel/.bashrc /etc/skel/.profile /root/
echo 'PS1="\`if [ \$? = 0 ]; then echo \[\e[37m\]^_^[\u@\H:\w]\\$ \[\e[0m\]; else echo \[\e[31m\]O_O[\u@\H:\w]\\$ \[\e[0m\]; fi\`"' >> /root/.bashrc \
|| error "Unable to setup PS1, exit status = " $?
