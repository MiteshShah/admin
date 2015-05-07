#!/bin/bash



# Install required packages
sudo apt-get install pdftk

INPUT_FILE=$1
PASSWORD=$2
OUTPUT_FILE=$3

# Remove password from pdf files
pdftk $INPUT_FILE input_pw $PASSWORD output $OUTPUT_FILE
