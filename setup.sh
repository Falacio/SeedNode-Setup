#!/bin/bash
# SeedNode - Masternode Setup Script V2.0 for Ubuntu 16.04 LTS
# (c) 2018 by Allroad. Forked by Falacio.
#
# Script will attempt to autodetect primary public IP address
# and generate masternode private key unless specified in command line
#
# Usage:
# bash setup.sh [port] [coin] [Release url]
#
# Example: Set up a Reef SeedNode at port 11058
# bash setup.sh 11058 reef https://github.com/reefcoin-io/reefcore/releases/download/v0.6.0/reefcore_linux.zip


#Process command line parameters
#TCP port
PORT=$1
client=$2
client+=-cli
daemon=$2
daemon+=d

#Color codes
RED='\033[0;91m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

#Clear keyboard input buffer
function clear_stdin { while read -r -t 0; do read -r; done; }

#Delay script execution for N seconds
function delay { echo -e "${GREEN}Sleep for $1 seconds...${NC}"; sleep "$1"; }

clear

# Determine primary public IP address
dpkg -s dnsutils 2>/dev/null >/dev/null || sudo apt-get -y install dnsutils
publicip=$(dig +short myip.opendns.com @resolver1.opendns.com)

if [ -n "$publicip" ]; then
    echo -e "${YELLOW}IP Address detected:" $publicip ${NC}
else
    echo -e "${RED}ERROR: Public IP Address was not detected!${NC} \a"
    clear_stdin
    read -e -p "Enter VPS Public IP Address: " publicip
    if [ -z "$publicip" ]; then
        echo -e "${RED}ERROR: Public IP Address must be provided. Try again...${NC} \a"
        exit 1
    fi
fi

#Installing Wallet files

mkdir ~/$2
cd ~/$2
wget $3
unzip *.zip
tar -xzvf *.gz
rm *.gz
rm *.zip
 
#Create datadir
if [ ! -f ~/.$2core/$2.conf ]; then 
 	sudo mkdir ~/.$2core
fi

./$daemon
delay 5

#Setting auto start cron job for reefd
cronjob="@reboot sleep 30 && ./$daemon"
crontab -l > tempcron
if ! grep -q "$cronjob" tempcron; then
    echo -e "${GREEN}Configuring crontab job...${NC}"
    echo $cronjob >> tempcron
    crontab tempcron
fi
rm tempcron

#Authors: Allroad and Falacio. 2018

# EOF
