#!/bin/bash
# Mount smb network drive
# This script is the automated version of my guide.
# The guide link https://github.com/berryflake/linuxgoody/guides/mount_network_drive.md 
# This script is only tested with popos 20.04 in a VM. Thus, if you find an issue, report it to me.
# Run this script as root, or sudo?(not sure will need testing), for now, use root user.
# This script is only support ubuntu based system e.g. ubuntu, popos...
# Version 0.1 alpha

# Set default variables
LCDIR=server        # local directory
USRID=1000          # user id
RMIP='127.0.0.1'    # remote ip
RMDIR=na            # remote directory
RMUSR=user          # remote username
RMPASSWD=password   # remote password

# idea: user input var, auto gen command and added to fstab

# check for root access.
if [ $(whoami) != 'root' ]
then
    echo "This script can only run under root!"
    exit 1
fi

clear

# install dependency.
#yes Y | apt-get install cifs-utils

# creating local folder for mounting.
while true
do
    read -r -p "Would you like your mountpoint folder name to be $LCDIR ? [y/N] " YN_LCDIR
    case $YN_LCDIR in
        [yY]|[yY][eE][sS])
        # if yes, break the loop.
        break 
        ;;
        [nN]|[nN][oO])
        # if no, ask user to input naming and run the while again.
        while true
        do
            # check naming
            while true
            do
                read -r -p "Input your naming : " LCDIR
                if [[ "${LCDIR}"  = *[!A-Za-z0-9_-]* ]]
                then
                    # limit the use of special characters to save some brain cells.
                    echo "Only [ A-Za-z0-9_- ] characters are allowed."
                else
                    # if the naming is legal, break the loop
                    break
                fi
            done
            # end check naming
            read -r -p "Your naming is now: $LCDIR , Are you sure? [y/N] " YN_LCDIR
            case $YN_LCDIR in
                [yY]|[yY][eE][sS])
                # break the loop.
                break
                ;;
                # everything else, return for reentering.
                *)
                ;;
            esac
        done
        break
        ;;
        * )
        # in case of unexpected input.
        echo $YN_LCDIR "is an invalid input..."
        ;;
    esac
done

# keep going ... later on



# something for the future 
#echo "ligel name to create: ${LCDIR// /_}"
#echo "ligel name for fstab : ${LCDIR// /\040}"

#uid=$( id -u )
#echo $uid



#!/bin/bash
# check user id

#id -un # for username
#id -u # for uid

# ask do u know your username of the macshine
# if yes prompt input
# if not, ls all user on the system for them to lookup. or show them command to do so.


