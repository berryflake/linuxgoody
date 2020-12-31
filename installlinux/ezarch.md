# Ezarch
### Arch Linux installation guide
### Installation needs ethernet connected.

- Tested on VM
- Source/Video: [MentalOutlaw](https://www.youtube.com/watch?v=rUEnS1zj1DM)

## 1) Boot menu
```
Arch Linux insrall medium (x86_64, BIOS)
```

- Entre and wait until booting into root shell


## 2) Connect to network
Check if your computer has an ethernet port, I'm recommending using a physical port for the installation.

### 2.1) LAN
- If you use a physical ethernet port, and your router is set on DHCP, then you most likely already have internet-connected.
- Check connection via 'ip a' , and locate your network card for info.

```
ip a
```

- After that, ping a server to confirm internet connection.
```
ping archlinux.org
```
- When ping successfully, **Ctrl+Z** to quit ping and proceed.

### 2.2) WLAN
I'm not yet tested on a physical machine, please refer to the official document [HERE](https://wiki.archlinux.org/index.php/Iwctl#iwctl)
- Following comman is from the offical document.

- Enter wireless daemon
```
iwctl
```
- If you don't know your wireless device name, list all Wi-Fi devices
```
device list
```
- Then, scan networks
```
station +[device] scan
```
- After that, list all available networks
```
station +[device] get-networks
```
- At last, connect to a network
```
station +[device] connect +[SSID]
```
- *If your network **requires password**, you will be asked to enter it. Alternatively, you can supply it as a command line argument*
```
iwctl --passphrase +[password] station +[device] connect +[SSID]
```

- Check connection via 'ip a' , and locate your network card for info.

```
ip a
```

- After that, ping a server to confirm internet connection.
```
ping archlinux.org
```
- When ping successfully, **Ctrl+Z** to quit ping and proceed.

## 3) Enable NTP Service sync
- NTP syncing by calling time date control 'timedatectl'

```
timedatectl set-ntp true
```

## 4) Identify which disk to install
```
lsblk
```
```
[EXAMPLE RETURN]
 ------------------------------------------------------------
 NAME   NAJ:NIN RM   SIZE RO  TYPE  MOUNTPOINT
 loop0    7:0    0 512.3M  1  loop  /run/archiso/sfs/airootfs
 sda      8:0    0 119.6G  0  disk  
 sr0     11:0    0   648M  0  rom   /run/archiso/bootmnt
 ------------------------------------------------------------
 [END OF EXAMPLE]
```

- llocate disk name, in this case 'sda' is the target disk
- [lsblk](#) list all block devices.


## 5) Partitioning disk
```
cfdisk /dev/sda
```

- dev stands for devices
- [cfdisk](#) Partitioning disk ``` cfdisk /dev/your_disk_name ```

## 6) 
```

Select label type

gpt   # If disk is greater than 2TB
dos   # If disk is smaller than above
sgi   # Not covered in this installation
sun   # Not covered in this installation

```
- In this installation, I'll be using dos as an example.
```
dos
```


## 7) Create partitions 

1. Select [  **New**  ] and enter
2. Create 'boot' partition, usually between (128 ~ 512M). ('256M' In this example) Hit enter to confirm.
3. Select [  **New**  ] and enter
4. Create '/' partition. (Here I allocate the rest of the remaining space) Hit enter to confirm.
5. To make 'boot' partition bootable by hitting 'B' on the keyboard or hit [  **Bootable**  ] button to comfirm.
6. Once you see  '* ' symbol on under 'Boot' column, means you have made the partition bootable.
7. Hit [  **Write**  ] to write change.
8. Hit [  **Quit**  ] to exit the tool.

- Linux system can run with only **'boot'** and **'/'** partition.
- **'Swap'**, **'/root'**and **'/home'** can be excluded.
- **[Swap]** partition is only good for if the system that has less than 4G of memory. Can cause system slowdown.
- **[/root]** and **[/home]** partition is usually created if you planning to create more than one user.

## 8) Verify disk partition
```
lsblk
```

```
[EXAMPLE RETURN]
 ------------------------------------------------------------
 NAME   NAJ:NIN RM   SIZE RO  TYPE  MOUNTPOINT
 loop0    7:0    0 512.3M  1  loop  /run/archiso/sfs/airootfs
 sda      8:0    0 119.6G  0  disk  
 |_sda1   8:1    0   256M  0  part  
 |_sda2   8:2    0 118.9G  0  part  
 sr0     11:0    0   648M  0  rom   /run/archiso/bootmnt
 ------------------------------------------------------------
 [END OF EXAMPLE]
```

## 9) Format partition
```
mkfs.ext4 /dev/sda1
mkfs.ext4 /dev/sda2
```

- Usage
```
mkfs.+[file_system] + [partiion_name]
```
- Here uses ext4 as an example.


## 10) Mount partitions
```
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
```
- [mount](#) '/ev/sda2' Partition to '/mnt' directory first, so that we can create the directory for boot partition.
- [mkdir](#) '/mnt/boot' Make **'boot'** directory.
- [mount](#) '/dev/sda1' Partition to '/mnt/boot' directory.


## 11) Verify disk mounting
```
lsblk
```

```
[EXAMPLE RETURN]
 ------------------------------------------------------------
 NAME   NAJ:NIN RM   SIZE RO  TYPE  MOUNTPOINT
 loop0    7:0    0 512.3M  1  loop  /run/archiso/sfs/airootfs
 sda      8:0    0 119.6G  0  disk  
 |_sda1   8:1    0   256M  0  part  /mnt/boot
 |_sda2   8:2    0 118.9G  0  part  /mnt
 sr0     11:0    0   648M  0  rom   /run/archiso/bootmnt
 ------------------------------------------------------------
 [END OF EXAMPLE]
```
- If mount successfully, you should see mount path under MOUNTPOINT.


## 12) Utilize [ pacstrap ] to install initial software and firmware
```
pacstrap /mnt base base-devel linux linux-firmware vim nano
```

- Usage
```
pacstrap + [mountpoint] + [options]
```

- This process might take several minutes, be patient.
- [Pacstrap](https://jlk.fjfi.cvut.cz/arch/manpages/man/pacstrap.8) is almost like a setup scrtips.


## 13) Generate fstab
- Generate fstab with genfstab

1. Quick and dirty
```
genfstab + [mountpoint] 
```
2. Precise and clean
```
genfstab + [options] + [mountpoint] >> /mnt/etc/fastab
```
- There's two way of doing it, the method [1] is the easy way, using the mountpoint to generate the fastab. This could cause problems later on, especially if you have more than one drive in your system. Because device name like 'sda' is not an unique identifier, and could be changed if one of them were to fail. Therefore, I recommend using the second method, using UUID to generate the fastab.

**Method [1]**
```
genfstab /mnt
```
```
[EXAMPLE RETURN]
 ------------------------------------------------------------
# UUID=0cu53dix3-3ns3-8934-d259-358bd83b3k83
/dev/sda2            /                    ext4            rw,relatime     0 1

# UUID=0a44n5no3-29cnw-2234-c298-shdi92103t7
/dev/sda2            /                    ext4            rw,relatime     0 1
 ------------------------------------------------------------
 [END OF EXAMPLE]
```
- UUID is commented out.


**Method [2]**
```
genfstab -U /mnt >> /mnt/etc/fstab
```
```
[EXAMPLE RETURN]
 ------------------------------------------------------------
# /dev/sda2            /                    ext4            rw,relatime     0 1
UUID=0cu53dix3-3ns3-8934-d259-358bd83b3k83

# /dev/sda2            /                    ext4            rw,relatime     0 1
UUID=0a44n5no3-29cnw-2234-c298-shdi92103t7
 ------------------------------------------------------------
 [END OF EXAMPLE]
```
- sda is commented out.


## 14) Chrooting
```
arch-chroot /mnt /bin/bash
exit
```

-[Readmore](https://wiki.archlinux.org/index.php/Chroot) About Chroot.


## 15) Install network manager and grub
```
pacman -S networkmanager grub
```

-[networkmanager](#) If you don't want internet, don't install it.
-[grub](#) If you want to manually boot your system, don't install it.
-[pacman](#) Package manager, is like **apt** in debian/-based system.


## 16) Set NetworkManager start on boot
```
systemctl enable NetworkManager 
```

-[systemctl](#) system control +[options] +[services]

## 17) Configure grub
```
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```
- Do not put grub in partition such as **[sda1, sda2 ...]**, grub is configure for the entire harddisk.
- [grub-mkconfig](#) Generate config file.
- Check the output, see if there a Linux image found. If not, check the **[pacstrap]** process.


## 18) Set root password
```
passwd
```
- [passwd](#) Set password for current user.

## 19) Generate locale
```
nano /etc/locale.gen
locale-gen
```
- Search the language you wanna use and **uncomment** it. Then save and exit.
- [locale](#) Selecting language for the system

## 20) Create locale.conf
```
nano /etc/locale.conf
```
- **Chose your language**
```
LANG=en-US.UTF-8
```

## 21) Change hostname
```
nano /etc/hostname
```
- **Chose your hostname**
```
berry-arch-vm
```

## 22) Change timezoom
```
ln -sf /sur/share/zoneinfo/
```

- Using **[tab]** to see all available country and regions
```
ln -sf /sur/share/zoneinfo/PRC /etc/localtime
```

### You are done!
#### Now you can install neofetch. ```pacman -S neofetch && neofetch```
There is more you can do after installing the base system, installing a desktop environment, office suite, etc.
