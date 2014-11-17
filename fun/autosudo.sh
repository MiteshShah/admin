#!/bin/bash

FILE=$1

# Check write permission
if [ -w $FILE ]
then
        /usr/bin/vim $FILE
else
	# Use sudo if we dont have write permissions
        sudo /usr/bin/vim $FILE
fi
