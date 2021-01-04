# Mount network drive guide
#### Mounting Network or SMB network drive to local directory.
#### This tutorial is made from [SpaceRex](https://youtu.be/RIS482WvbM4)'s youtube tutorial, If you like a video walkthrough, go check out his video.

### 1) Install cifs-utils

```
sudo apt-get install cifs-utils
```

### 2) Make directory for mountpoint
- The location is generally preferred in your home directory.
- Change the folder name ```mountpoint``` to your liking.

```
mkdir ~/mountpoint
```

- To check your folder, use ```ls``` to see if the folder has been made.

### 3) Find user id 
- The user id is used to specify the accessibility of the folder

```
id
```

- Locate the ```uid=1000(user_name)``` it usually the frist one, and the id usually is '1000'.
- If you have multiple users on the system, then check by the ```(user_name)```.

### 4) Manually mount the drive
- Change ```remotename``` to your smb username.
- Change ```remotepassword``` to your smb password.
- Change ```127.0.0.1/remotedirectory``` to your smb server's ip and directory that you wish to mount.
- Change ```mountpoint``` to your local mountpoint name.

```
sudo mount -t cifs -o username=remotename,password=remotepassword,uid=1000 //127.0.0.1/remotedirectory ~/mountpoint
```

- [[mount]](https://www.computerhope.com/unix/umount.htm) **-t** Mount type e.g. ```cifs```
- [[cifs]](https://linux.die.net/man/8/mount.cifs) **-o** optional parameters e.g. ```username``` (smb file system), ```password```
- If your remote directory has space between the naming, add single quote ```''``` to the command e.g. ```... //127.0.0.1/'remote directory' ...```
- If your smb password has special characters e.g. ```#$^&*!',.``` then the connection will fail, one of the solution is use ```credentials``` file. (will be mentioned later on)

#### 4.1) Mount check
- After you hit enter, check if the mount was successful.
- You can use the GUI file manager, or use command like ``` ls ``` to check.
- If you see your remote files/folders mean the connection is established successfully.

```
ls ~/mountpoint
```
- That is for the basic, if you only wanted to mount it this time, then you are done!
- If you want to mount if every time during startup, then continue reading.
---

### 5) Secure your info with credentials
- By default, everyone can read the fstab file, thus if you using plain text username and password like above, your smb server might get an unwanted visit.
- By using credentials file, you get to use a more complex password with special characters e.g. ```#$^&*()!',.``` to ferder secure your account.
- The process of creating the credentials file must be under root for security.
- Change the name ```.key``` to your liking, but you must add period ```.``` at the beginning of the filename to hide it. e.g ```.tomysmb```, ```.toserver```, ```.totallynotusernameandpassword```...

#### 5.1) creating credentials file
- [[nano]](https://www.nano-editor.org/) Nano is my preferred of text editor, you can use whatever you like. e.g. *vi* , *vim* 

```
sudo su
nano /root/.key
```

#### 5.2) set username and password
- After changing the username and password to yours, **save** ```Ctrl+O``` and **exit** ```Ctrl+X``` .

```
username=remotename
password=remotepassword
```
#### 5.3) Changing the credentials file permission to root only

```
chmod 700 /root/.key
```

- [[chmod]](https://www.computerhope.com/unix/uchmod.htm) Set the permissions of files or directories.


### 6) Mount the drive during startup
- After making and securing the credentials file, is time to edite the ```fstab``` file.

```
sudo nano /etc/fstab
```

- Create a new line
- Type in the following

```
//127.0.0.1/remotedirectory /home/user_name/mountpoint cifs credentials=/root/.key,uid=1000 0 0
```
- Change ```127.0.0.1/remotedirectory``` to your smb server's ip and directory that you wish to mount.
- Change ```.../user_name/mountpoint``` to your username and mountpoint name.
- Change ```.../.key``` to your credentials filename.
- If your remote directory has space between the naming, replace the space with ```\040``` e.g. ```... //127.0.0.1/remote\040directory ...```
- [[fstab]](https://help.ubuntu.com/community/Fstab)  Is a file that automate the process of mounting partition of the internal devices, CD/DVD devices, and network shares (samba/nfs/sshfs).

### 7) Testing

- To test mounting, run ```sudo mount -a```
- If mount successfully, then ```reboot``` to see if it also works on startup.

## You are done!

### Softwares
1. [[cifs-utils]](https://wiki.samba.org/index.php/LinuxCIFS_utils) Tool to mount SMB/CIFS shares on Linux.
