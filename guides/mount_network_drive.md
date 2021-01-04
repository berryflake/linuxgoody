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
- Change ```remotename``` to your remote username.
- Change ```remotepassword``` to your remote password.
- Change ```127.0.0.1/remotedirectory``` to your SMB server's ip and directory that you wish to mount.
- Change ```mountpoint``` to your local mountpoint folder name.

```
sudo mount -t cifs -o username=remotename,password=remotepassword,uid=1000 //127.0.0.1/remotedirectory ~/mountpoint
```
- [[mount]](https://www.computerhope.com/unix/umount.htm) **-t** Mount type e.g. ```cifs```
- [[cifs]](https://linux.die.net/man/8/mount.cifs) **-o** optional parameters e.g. ```username``` (smb file system), ```password```
- If your remote directory has space between the naming, add single quote ```''``` to the command e.g. ```... //127.0.0.1/'remote directory' ...```
- ```~/``` To your gome directory.

### 5) 

### 6) 

- To test mounting, run ```mount -a```

```
Pending
```

### Softwares
1. [[cifs-utils]](https://wiki.samba.org/index.php/LinuxCIFS_utils) Tool to mount SMB/CIFS shares on Linux.
2. 
3. 
4. 
