#!/bin/bash
# Mount smb network drive
# This script is the automated version of my guide.
# The guide github.com/berryflake/linuxgoody/guides/mount_network_drive.md
# This script is only tested ubuntu based system e.g. ubuntu, popos...
# Run this script as root.
# Version 0.9 alpha

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
KEYFILE='.smbkey'   # credentials file mane

# idea: user input var, auto gen command and added to fstab

# Check for root access.
if [ $(whoami) != 'root' ]; then
    echo "This script can only run under root!"
    exit 1
fi
# End check for root access

clear

# Install dependency.
yes Y | apt-get install cifs-utils
# End install dependency

# Creating local folder for mounting.
while true
do
	clear
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
    echo "Hit enter when you're done."
    echo ""
    read -r -p "1/3 - Input your username: " USRNAME
    read -r -p "2/3 - Input your user id (UID): " USRID
    read -r -p "3/3 - Input your group id (GID): " USRGID
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
        echo "info saved."
        break 
        ;;
        [nN]|[nN][oO])
        # if no, ask user to reinput.
        echo "Changing info"
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
        # if no, ask user to input home directory manually.
        while true
            do
                read -r -p "Edite your home directory manually: " COS_USRDIR
                if [[ "${COS_USRDIR}"  = *[!A-Za-z0-9/_-]* ]]
                then
                    # limit the use of special characters to save some brain cells.
                    echo "ERROR: Only [ A-Z a-z 0-9 /_- ] characters are allowed."
                    echo "NOTE: Do not use ~/ to shorten your path, use the full path."
                else
                    case $COS_USRDIR in
                        */)
                        echo "ERROR: / should not be at the end."
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
    echo "Hit enter when you're done."
    echo ""
    read -r -p "1/4 - Your server ip (ipv4): " RMIP
    read -r -p "2/4 - Your server username: " RMUSR
    read -r -p "3/4 - Your server password: " RMPASSWD
    read -r -p "4/4 - Your server directory (Folder name): " RMDIR
    clear
    echo "=========|Setting Overview|========="
    echo "Server ip:" $RMIP
    echo "Server username: " $RMUSR
    echo "Server password: " $RMPASSWD
    echo "Server path in full: " //$RMIP/$RMDIR
    echo "===================================="
    read -r -p "Confirm your setting [y/N] " YN_USRINFO
    case $YN_USRINFO in
        [yY]|[yY][eE][sS])
        # if yes, break the loop.
        echo "info saved."
        break 
        ;;
        [nN]|[nN][oO])
        # if no, ask user to reinput.
        echo "Changing info"
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
# End make mountingpoint on user home directory

# Asking if user if they want to make it mount on startup.
while true
do
    clear
    echo ""
    echo "==================================="
    echo " Make automount"
    echo "==================================="
    echo ""
    echo "Do you want your network drive to be mounted during startup?"
    echo ""
    echo "If yes, the script will add a command to your fstab."
    echo "Therefore mount it automatically during startup."
    echo "Best for a static network, e.g. Tower PC, or laptop that stays at the same network."
    echo ""
    echo "If no, the script will generate a script which you need to run it to mount the network drive."
    echo "This process needs to be done manually every time you boot up the system."
    echo "Suitable for those who travel a lot between different networks."
    echo ""
    echo "==================================="
    echo ""
    read -r -p "Mount it automatically during startup? [y/N] " YN_AUTOMOUNT
    case $YN_AUTOMOUNT in
        [yY]|[yY][eE][sS])
            # add to fstab
            # Create credentials file
            echo "username=$RMUSR" >> /root/$KEYFILE
            echo "password=$RMPASSWD" >> /root/$KEYFILE
            # Change credentials - owndership, permission
            chown root:root /root/$KEYFILE
            chmod 700 /root/$KEYFILE
            clear
            echo ""
            echo "===================================================="
            echo " Credentials is created"
            echo "===================================================="
            echo ""
            cat /root/$KEYFILE
            echo ""
            echo "===================================================="
            echo "Your credentials file is stored at /root/$KEYFILE "
            echo "===================================================="
            # End create credentials file
            # Backup fstab
            cp /etc/fstab /etc/fstab.bak
            # writing to fstab
            echo "# Adding SMB Mount during start" >> /etc/fstab
            if [ $COS_USRDIR != '/' ]
            then
                echo "//$RMIP/$RMDIR $COS_USRDIR/$LCDIR cifs credentials=/root/$KEYFILE,uid=$USRID 0 0" >> /etc/fstab
            else
                echo "//$RMIP/$RMDIR $USRDIR$USRNAME/$LCDIR cifs credentials=/root/$KEYFILE,uid=$USRID 0 0" >> /etc/fstab
            fi
            # End writing to fstab
            echo "A backup is created for fstab at /etc/fstab.bak"
            break
            ;;
        [nN]|[nN][oO])
            # gen script
            # Generate script, for the user to run when they please
            clear
            echo ""
            echo "==========================================="
            echo " Script generated"
            echo "==========================================="
            echo "This script allows you to mount to your SMB Network drive, invalid when next boot."
            echo ""
            # Generating
            if [ $COS_USRDIR != '/' ]
            then
                echo "mount -t cifs -o username=$RMUSR,password=$RMPASSWD,uid=$USRID //$RMIP/$RMDIR $COS_USRDIR/$LCDIR" >> $COS_USRDIR/mapdrive.sh
            else
                echo "mount -t cifs -o username=$RMUSR,password=$RMPASSWD,uid=$USRID //$RMIP/$RMDIR $USRDIR$LCDIR" >> $USRDIR$USRNAME/mapdrive.sh
            fi
            # Generated
            echo "The script is stored on your home directory $USRDIR called mapdrive.sh"
            echo "Run it with sudo privilege."
            # End generate script
            break
            ;;
        *)
            echo $YN_AUTOMOUNT "is an invalid input..."
            sleep 1
            ;;
    esac
done


# something for the future ?
#echo "ligel name to create: ${LCDIR// /_}"
#echo "ligel name for fstab : ${LCDIR// /\040}"
