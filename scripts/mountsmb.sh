#!/bin/bash
# Mount smb network drive
# This script is the automated version of my guide.
# The guide https://github.com/berryflake/linuxgoody/blob/main/guides/mount_network_drive.md
# This script is only tested with popos 20.04 in a VM. Thus, if you find an issue, report it to me.
# Run this script as root, or sudo?(not sure will need testing), for now, use root user.
# This script is only support ubuntu based system e.g. ubuntu, popos...
# Version 0.1 alpha

# Set default variables
LCDIR=server        # local directory
USRNAME=NA          # user name
USRDIR=/home/       # home directory
COS_USRDIR=/        # Custom mount directory
USRID=1000          # user id
USRGID=1000         # user group id
RMIP='0.0.0.0'      # remote ip
RMDIR=/             # remote directory
RMUSR=user          # remote username
RMPASSWD=password   # remote password

# idea: user input var, auto gen command and added to fstab

# Check for root access.
if [ $(whoami) != 'root' ]
then
    echo "This script can only run under root!"
    exit 1
fi
# End check for root access

clear

# Install dependency.
#yes Y | apt-get install cifs-utils
# End install dependency

# Creating local folder for mounting.
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
        *)
        # in case of unexpected input.
        echo $YN_LCDIR "is an invalid input..."
        ;;
    esac
done

# Define username,id,group
clear
while true
do
    # find your username and user id
    awk -F: '{ print $1 , $3 , $4}' /etc/passwd

    echo ""
    echo "==========================================="
    echo "Find your username, UID, GID from the list."
    echo "==========================================="
    echo ""
    read -r -p "Input your username: " USRNAME
    read -r -p "Input your UID: " USRID
    read -r -p "Input your GID: " USRGID
    clear
    echo "==========|User Info|========="
    echo "Username: " $USRNAME
    echo "User ID [UID]: " $USRID
    echo "Group ID [GID]: " $USRGID
    echo "=============================="
    read -r -p "Confirm your info [y/N] " YN_USRINFO
    case $YN_USRINFO in
        [yY]|[yY][eE][sS])
        # if yes, break the loop.
        echo "info is accepted."
        break 
        ;;
        [nN]|[nN][oO])
        # if no, ask user to input naming and run the while again.
        echo "Changing info"
        # find your username and user id
        ;;
        *)
        # in case of unexpected input.
        echo $YN_USRINFO "is an invalid input..."
        ;;
    esac
done
# End define username,id,group

# Define home directory
while true
do
    read -r -p "Is this your home directory? $USRDIR$USRNAME [y/N] " YN_USRDIR
    case $YN_USRDIR in
        [yY]|[yY][eE][sS])
        # if yes, break the loop.
        echo "info is accepted."
        echo $USRDIR$USRNAME # Home dir, remove later, only for testing.
        break 
        ;;
        [nN]|[nN][oO])
        # if no, ask user to input naming and run the while again.
        while true
            do
                read -r -p "Edite your home directory manually: " COS_USRDIR
                if [[ "${COS_USRDIR}"  = *[!A-Za-z0-9/_-]* ]]
                then
                    # limit the use of special characters to save some brain cells.
                    echo "ERROR: Only [ A-Za-z0-9/_- ] characters are allowed."
                    echo "NOTE: Do not use ~/ to shorten your path, use the full path."
                else
                    case $COS_USRDIR in
                        */)
                        echo "ERROR: / is NOT at the end, delete it for the script to work."
                        ;;
                        *)
                        echo $COS_USRDIR # remove later, only for testing.
                        break
                        ;;
                    esac
                    #break
                fi
            done
        # find your username and user id
        break
        ;;
        *)
        # in case of unexpected input.
        echo $YN_USRDIR "is an invalid input..."
        ;;
    esac
done
# End define home directory

# Define remote setting
while true
do
    clear
    echo ""
    echo "==========================================="
    echo " Remote setting"
    echo "==========================================="
    echo ""
    read -r -p "Your remote ip: " RMIP
    read -r -p "Your remote username: " RMUSR
    read -r -p "Your remote password: " RMPASSWD
    read -r -p "Your remote mountpoint: " RMDIR
    clear
    echo "=========|Setting overview|========="
    echo "Remote ip:" $RMIP
    echo "Remote username: " $RMUSR
    echo "Remote password:  " $RMPASSWD
    echo "Remote directory:  " //$RMIP/$RMDIR
    echo "===================================="
    read -r -p "Confirm your info [y/N] " YN_USRINFO
    case $YN_USRINFO in
        [yY]|[yY][eE][sS])
        # if yes, break the loop.
        echo "info is accepted."
        break 
        ;;
        [nN]|[nN][oO])
        # if no, ask user to input naming and run the while again.
        echo "Changing info"
        # find your username and user id
        ;;
        *)
        # in case of unexpected input.
        echo $YN_USRINFO "is an invalid input..."
        ;;
    esac
done
# End define remote setting

# Make mountingpoint on user home directory
if [ $COS_USRDIR != '/' ]
then
    mkdir $COS_USRDIR/$LCDIR
    chown $USRNAME:$USRNAME $COS_USRDIR/$LCDIR
    chmod 775 $COS_USRDIR/$LCDIR
else
    mkdir $USRDIR$USRNAME/$LCDIR
    chown $USRNAME:$USRNAME $USRDIR$USRNAME/$LCDIR
    chmod 775 $USRDIR$USRNAME/$LCDIR
fi

# Print a temperoty mount command
clear
echo ""
echo "==========================================="
echo " Testing setting"
echo "==========================================="
echo ""
if [ $COS_USRDIR != '/' ]
then
    echo "sudo mount -t cifs -o username=$RMUSR,password=$RMPASSWD,uid=$USRID //$RMIP/$RMDIR $COS_USRDIR/$LCDIR"
else
    echo "sudo mount -t cifs -o username=$RMUSR,password=$RMPASSWD,uid=$USRID //$RMIP/$RMDIR $USRDIR$USRNAME/$LCDIR"
fi



# something for the future 
#echo "ligel name to create: ${LCDIR// /_}"
#echo "ligel name for fstab : ${LCDIR// /\040}"

#uid=$( id -u )
#echo $uid



#!/bin/bash
# check user id

#id -un # for username
#id -u # for uid
