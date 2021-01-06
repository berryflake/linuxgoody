#!/bin/bash
# Mount smb network drive
# This script is the automated version of my guide.
# The guide github.com/berryflake/linuxgoody/guides/mount_network_drive.md
# This script is only tested on ubuntu based system e.g. ubuntu, popos...
# No need to run this script as root.
# Version 0.3 alpha

# Check for root access.
if [ $(whoami) == 'root' ]
then
    echo "This script cannot run as root!"
    exit 1
fi
# End check for root access

# Default variables
LCDIR=server        # local directory
USRNAME=$(id -un)   # user name of the macshine
USRID=$(id -u)      # user id
USRGID=$(id -g)     # user group id
USRDIR=$HOME        # home directory path
COS_USRDIR=/        # Custom user directory
RMIP='0.0.0.0'      # remote ip
RMDIR=/             # remote directory
RMUSR=user          # remote username , might get deleted in the future
RMPASSWD=password   # remote password , might get deleted in the future

echo $USRDIR

# Install dependency. this is not the one needed, just for testing.
#yes Y | sudo apt-get install sysbench
# End install dependency

# Get name for mounting folder.
while true
do
    read -r -p "Would you like your mountpoint name $LCDIR ? [y/N] " YN_LCDIR
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
                read -r -p "Custom your naming : " LCDIR
                if [[ "${LCDIR}"  = *[!A-Za-z0-9_-]* ]]
                then
                    # limit the use of special characters to save some brain cells.
                    echo "ERROR: Only [ A-Z a-z 0-9 _- ] characters are allowed."
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
# End get name for mounting folder.

# Define username,id,group
clear
while true
do
    clear
    echo ""
    echo "==========|User Info|========="
    echo "Username: " $USRNAME
    echo "User ID [UID]: " $USRID
    echo "Group ID [GID]: " $USRGID
    echo "=============================="
    echo ""
    read -r -p "Are the info above correct? [y/N] " YN_USRINFO
    case $YN_USRINFO in
        [yY]|[yY][eE][sS])
            # Confirm info
            echo "Info saved."
            break
            ;;
        [nN]|[nN][oO])
            # Change info
            # find your username and user id
            clear
            awk -F: '{ print $1 , $3 , $4}' /etc/passwd
            echo ""
            echo "==========================================="
            echo "Find your username, UID, GID from the list."
            echo "==========================================="
            echo ""
            read -r -p "Input your username: " USRNAME
            read -r -p "Input your UID: " USRID
            read -r -p "Input your GID: " USRGID
            ;;
        *)
            echo $YN_USRINFO "is an invalid input..."
            sleep 1
            ;;
    esac
done
# End define username,id,group

# Define home directory
while true
do
    read -r -p "Is this your home directory? $USRDIR [y/N] " YN_USRDIR
    case $YN_USRDIR in
        [yY]|[yY][eE][sS])
        # if yes, break the loop.
        echo "info saved."
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
                        read -r -p "Your path is $COS_USRDIR ? [y/N] " YN_USRDIR
                        case $YN_USRDIR in
                            [yY]|[yY][eE][sS])
                            # If yes, break loop
                            echo "Info saved."
                            break
                            ;;
                            *)
                             # everything else, return for reentering.
                            ;;
                        esac
                        ;;
                    esac
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
    echo "Remote password: " $RMPASSWD
    echo "Remote directory: " //$RMIP/$RMDIR
    echo "===================================="
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
# End define remote setting

# Make mountingpoint on user home directory
if [ $COS_USRDIR != '/' ]
then
    mkdir $COS_USRDIR/$LCDIR
    chown $USRNAME:$USRNAME $COS_USRDIR/$LCDIR
    chmod 775 $COS_USRDIR/$LCDIR
else
    mkdir $USRDIR/$LCDIR
    chown $USRNAME:$USRNAME $USRDIR/$LCDIR
    chmod 775 $USRDIR/$LCDIR
fi
# End make mountingpoint on user home directory

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
    echo "sudo mount -t cifs -o username=$RMUSR,password=$RMPASSWD,uid=$USRID //$RMIP/$RMDIR $USRDIR/$LCDIR"
fi
# End print a temperoty mount command

# add fastab soon... ? need sudo or root access
