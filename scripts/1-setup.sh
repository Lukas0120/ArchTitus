#!/usr/bin/env bash
#github-action genshdoc
#
# @file Setup
# @brief Configures installed system, installs base packages, and creates user. 
echo -ne "
-------------------------------------------------------------------------
   █████╗ ██████╗  ██████╗██╗  ██╗████████╗██╗████████╗██╗   ██╗███████╗
  ██╔══██╗██╔══██╗██╔════╝██║  ██║╚══██╔══╝██║╚══██╔══╝██║   ██║██╔════╝
  ███████║██████╔╝██║     ███████║   ██║   ██║   ██║   ██║   ██║███████╗
  ██╔══██║██╔══██╗██║     ██╔══██║   ██║   ██║   ██║   ██║   ██║╚════██║
  ██║  ██║██║  ██║╚██████╗██║  ██║   ██║   ██║   ██║   ╚██████╔╝███████║
  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝   ╚═╝    ╚═════╝ ╚══════╝
-------------------------------------------------------------------------
                    Automated Arch Linux Installer
                        SCRIPTHOME: ArchTitus
-------------------------------------------------------------------------
"
source $HOME/ArchTitus/configs/setup.conf
echo -ne "
-------------------------------------------------------------------------
                    Network Setup 
-------------------------------------------------------------------------
"
pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
pacman-key --lsign-key F3B607488DB35A47
pacman -U --noconfirm 'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-keyring-2-1-any.pkg.tar.zst' 'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-mirrorlist-13-1-any.pkg.tar.zst' 'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v3-mirrorlist-13-1-any.pkg.tar.zst' 'https://mirror.cachyos.org/repo/x86_64/cachyos/pacman-6.0.2-7-x86_64.pkg.tar.zst'

cat << EOF >> /etc/pacman.conf
[cachyos-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist
SigLevel = Never

[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist
SigLevel = Never
EOF

pacman -Sy --noconfirm
pacman -Syu --noconfirm
pacman -S --noconfirm --needed git wget nano f2fs-tools dhcpcd freetype2
systemctl enable --now dhcpcd
echo -ne "
-------------------------------------------------------------------------
                    Setting up mirrors for optimal download 
-------------------------------------------------------------------------
"
pacman -S --noconfirm --needed pacman-contrib curl
pacman -S --noconfirm --needed reflector rsync grub arch-install-scripts git
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

nc=$(grep -c ^processor /proc/cpuinfo)
echo -ne "
-------------------------------------------------------------------------
                    You have " $nc" cores. And
			changing the makeflags for "$nc" cores. Aswell as
				changing the compression settings.
-------------------------------------------------------------------------
"
TOTAL_MEM=$(cat /proc/meminfo | grep -i 'memtotal' | grep -o '[[:digit:]]*')
if [[  $TOTAL_MEM -gt 8000000 ]]; then
sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$nc\"/g" /etc/makepkg.conf
sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g" /etc/makepkg.conf
sed "s,-mtune=generic,-mtune=native,g" -i /etc/makepkg.conf
#Enable link time optimizations
sed "s,\!lto,lto,g" -i /etc/makepkg.conf
fi
echo -ne "
-------------------------------------------------------------------------
                    Setup Language to US and set locale  
-------------------------------------------------------------------------
"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
timedatectl --no-ask-password set-timezone ${TIMEZONE}
timedatectl --no-ask-password set-ntp 1
localectl --no-ask-password set-locale LANG="en_US.UTF-8" LC_TIME="en_US.UTF-8"
ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
# Set keymaps
localectl --no-ask-password set-keymap ${KEYMAP}

# Add sudo no password rights
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
#Add parallel downloading
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sed "s,\#\Color,Color,g" -i /etc/pacman.conf
#Enable multilib
sed "s,\#\COMPRESSION=\"lz4\",COMPRESSION=\"lz4\",g" -i /etc/mkinitcpio.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
sed "s,\#\ set linenumbers, set linenumbers,g" -i /etc/nanorc
sed "s,\#\ set positionlog, set positionlog,g" -i /etc/nanorc
sed "s,\#\ set constantshow, set constantshow,g" -i /etc/nanorc
sed "s,\#\ set titlecolor bold\,white\,blue, set titlecolor bold\,lightwhite,g" -i /etc/nanorc
sed "s,\#\ set promptcolor lightwhite\,grey, set promptcolor lightwhite\,lightblack,g" -i /etc/nanorc
sed "s,\#\ set errorcolor bold\,white\,red, set errorcolor bold\,lightwhite\,red,g" -i /etc/nanorc
sed "s,\#\ set spotlightcolor black\,lightyellow, set spotlightcolor black\,lime,g" -i /etc/nanorc
sed "s,\#\ set selectedcolor lightwhite\,magenta, set selectedcolor lightwhite\,magenta,g" -i /etc/nanorc
sed "s,\#\ set stripecolor \,yellow, set stripecolor yellow,g" -i /etc/nanorc
sed "s,\#\ set statuscolor bold\,white\,green, set statuscolor bold\,white,g" -i /etc/nanorc
sed "s,\#\ set scrollercolor cyan, set scrollercolor cyan,g" -i /etc/nanorc
sed "s,\#\ set numbercolor cyan, set numbercolor magenta,g" -i /etc/nanorc
sed "s,\#\ set keycolor cyan, set keycolor cyan,g" -i /etc/nanorc
sed "s,\#\ set functioncolor green, set functioncolor green,g" -i /etc/nanorc
sed "s,\#\ include \"/usr/share/nano/\*.nanorc\", include \"/usr/share/nano/\*.nanorc\",g" -i /etc/nanorc
echo "include /usr/share/nano-syntax-highlighting/*.nanorc" >> /etc/nanorc
ln -s /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
ln -s /usr/share/fontconfig/conf.avail/10-hinting-full.conf /etc/fonts/conf.d
sed "s,\#export FREETYPE_PROPERTIES=\"truetype\:interpreter-version=40\",export FREETYPE_PROPERTIES=\"truetype\:interpreter-version=40\",g" -i /etc/profile.d/freetype2.sh
echo "blacklist k10temp" > /etc/modprobe.d/disable-k10temp.conf
echo "zenpower" > /etc/modules-load.d/zenpower.conf
pacman -Sy --noconfirm --needed

echo -ne "
-------------------------------------------------------------------------
                    Installing Base System  
-------------------------------------------------------------------------
"
# sed $INSTALL_TYPE is using install type to check for MINIMAL installation, if it's true, stop
# stop the script and move on, not installing any more packages below that line
if [[ ! $DESKTOP_ENV == server ]]; then
  sed -n '/'$INSTALL_TYPE'/q;p' $HOME/ArchTitus/pkg-files/pacman-pkgs.txt | while read line
  do
    if [[ ${line} == '--END OF MINIMAL INSTALL--' ]]; then
      # If selected installation type is FULL, skip the --END OF THE MINIMAL INSTALLATION-- line
      continue
    fi
    echo "INSTALLING: ${line}"
    sudo pacman -S --noconfirm --needed ${line}
  done
fi
echo -ne "
-------------------------------------------------------------------------
                    Installing Microcode
-------------------------------------------------------------------------
"
# determine processor type and install microcode
proc_type=$(lscpu)
if grep -E "GenuineIntel" <<< ${proc_type}; then
    echo "Installing Intel microcode"
    pacman -S --noconfirm --needed intel-ucode
    proc_ucode=intel-ucode.img
elif grep -E "AuthenticAMD" <<< ${proc_type}; then
    echo "Installing AMD microcode"
    pacman -S --noconfirm --needed amd-ucode
    proc_ucode=amd-ucode.img
fi

echo -ne "
-------------------------------------------------------------------------
                    Installing Graphics Drivers
-------------------------------------------------------------------------
"
# Graphics Drivers find and install
gpu_type=$(lspci)
if grep -E "NVIDIA|GeForce" <<< ${gpu_type}; then
    pacman -S --noconfirm --needed dkms nvidia-dkms nvidia-utils nvidia-settings mesa
elif lspci | grep 'VGA' | grep -E "Radeon|AMD"; then
    pacman -S --noconfirm --needed xf86-video-amdgpu
elif grep -E "Integrated Graphics Controller" <<< ${gpu_type}; then
    pacman -S --noconfirm --needed libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa
elif grep -E "Intel Corporation UHD" <<< ${gpu_type}; then
    pacman -S --needed --noconfirm libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils lib32-mesa
fi
#SETUP IS WRONG THIS IS RUN
if ! source $HOME/ArchTitus/configs/setup.conf; then
	# Loop through user input until the user gives a valid username
	while true
	do 
		read -p "Please enter username:" username
		# username regex per response here https://unix.stackexchange.com/questions/157426/what-is-the-regex-to-validate-linux-users
		# lowercase the username to test regex
		if [[ "${username,,}" =~ ^[a-z_]([a-z0-9_-]{0,31}|[a-z0-9_-]{0,30}\$)$ ]]
		then 
			break
		fi 
		echo "Incorrect username."
	done 
# convert name to lowercase before saving to setup.conf
echo "username=${username,,}" >> ${HOME}/ArchTitus/configs/setup.conf

    #Set Password
    read -p "Please enter password:" password
echo "password=${password,,}" >> ${HOME}/ArchTitus/configs/setup.conf

    # Loop through user input until the user gives a valid hostname, but allow the user to force save 
	while true
	do 
		read -p "Please name your machine:" name_of_machine
		# hostname regex (!!couldn't find spec for computer name!!)
		if [[ "${name_of_machine,,}" =~ ^[a-z][a-z0-9_.-]{0,62}[a-z0-9]$ ]]
		then 
			break 
		fi 
		# if validation fails allow the user to force saving of the hostname
		read -p "Hostname doesn't seem correct. Do you still want to save it? (y/n)" force 
		if [[ "${force,,}" = "y" ]]
		then 
			break 
		fi 
	done 

    echo "NAME_OF_MACHINE=${name_of_machine,,}" >> ${HOME}/ArchTitus/configs/setup.conf
fi
echo -ne "
-------------------------------------------------------------------------
                    Adding User
-------------------------------------------------------------------------
"
if [ $(whoami) = "root"  ]; then
    groupadd libvirt
    useradd -m -G wheel,libvirt -s /bin/bash $USERNAME 
    echo "$USERNAME created, home directory created, added to wheel and libvirt group, default shell set to /bin/bash"

# use chpasswd to enter $USERNAME:$password
    echo "$USERNAME:$PASSWORD" | chpasswd
    echo "$USERNAME password set"

	cp -R $HOME/ArchTitus /home/$USERNAME/
    chown -R $USERNAME: /home/$USERNAME/ArchTitus
    echo "ArchTitus copied to home directory"

# enter $NAME_OF_MACHINE to /etc/hostname
	echo $NAME_OF_MACHINE > /etc/hostname
else
	echo "You are already a user proceed with aur installs"
fi
if [[ ${FS} == "luks" ]]; then
# Making sure to edit mkinitcpio conf if luks is selected
# add encrypt in mkinitcpio.conf before filesystems in hooks
    sed -i 's/filesystems/encrypt filesystems/g' /etc/mkinitcpio.conf
# making mkinitcpio with linux kernel
    mkinitcpio -p linux
fi
echo -ne "
-------------------------------------------------------------------------
                    SYSTEM READY FOR 2-user.sh
-------------------------------------------------------------------------
"
