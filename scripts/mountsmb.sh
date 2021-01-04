#!/bin/bash
# Mount smb network drive
# This script is the automated version of my guide.
# The guide link https://github.com/berryflake/linuxgoody/guides/mount_network_drive.md 
# This script is only tested with popos 20.04 in a VM. Thus, if you find an issue, report it to me.
# Run this script as root, or sudo?(not sure will need testing), for now, use root user.
# Version 0.1 alpha

# NOT YET FINISHED , DO NOT USE IT.

if [ $(whoami) != 'root' ]
then
    echo This script can only run under root!
    exit 1
fi

clear

yes Y | apt-get install cifs-utils

echo ""
read -p 'Choose your mountpoint name: ' mountpointname
read -p 'Your mountpoint name is $mountpointname

uid=$( id -u )

echo $uid
