#!/bin/bash
# Mount smb network drive
# This script is the automated version of my guide.
# The guide link https://github.com/berryflake/linuxgoody/guides/mount_network_drive.md 
# This script is only tested with popos 20.04 in a VM. Thus, if you find an issue, report it to me.
# Run this script as root, or sudo?(not sure will need testing), for now, use root user.
# Version 0.1 alpha

# Set vars
LCDIR=server        # local directory
USRID=1000          # user id
RMIP='127.0.0.1'    # remote ip
RMDIR=na            # remote directory
RMUSR=user          # remote username
RMPASSWD=password   # remote password

# idea: user input var, auto gen command and added to fstab

if [ $(whoami) != 'root' ]
then
    echo "This script can only run under root!"
    exit 1
fi

clear

yes Y | apt-get install cifs-utils

#echo "Would you like your local mountpoint name to be" $LCDIR "?"
#read -p '[ Yes / No ] : ' TOF_LCDIR
while true
do
	read -r -p "Would you like your local mountpoint name to be" $LCDIR "? [Yes / No ] " YN_LCDIR
	case $YN_LCDIR in
		[yY][eE][sS][yY])
        echo "YES" # For testing
        break 
        ;;
        [nN][oO][nN])
        echo "NO" # For testing
        # ask user to input their naming and run the while again.
        while true
        do
        	read -r -p "Input your naming : " LCDIR
        	read -r -p "Your naming is: " $LCDIR "Are you sure? [Yes / No ] " YN_LCDIR
        	# more later.... is 6am.... god lord *damn*!!!
        break
        ;;
        *)
        echo "Invalid input..."
        ;;
    esac


uid=$( id -u )

echo $uid
