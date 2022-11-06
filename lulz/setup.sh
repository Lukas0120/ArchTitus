#!/usr/bin/env bash
#-------------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗████████╗██╗████████╗██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║╚══██╔══╝██║╚══██╔══╝██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║   ██║   ██║   ██║   ██║   ██║███████╗
#  ██╔══██║██╔══██╗██║     ██╔══██║   ██║   ██║   ██║   ██║   ██║╚════██║
#  ██║  ██║██║  ██║╚██████╗██║  ██║   ██║   ██║   ██║   ╚██████╔╝███████║
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝   ╚═╝    ╚═════╝ ╚══════╝
#-------------------------------------------------------------------------

#wget https://mirror.cachyos.org/llvm-bolt.tar.zst
#unzstd llvm-bolt.tar.zst
#tar xvf llvm-bolt.tar
#rm llvm-bolt.tar
#rm llvm-bolt.tar.zst
#mv ~/llvm ~/clang

echo "
###############################################################################
# Configuring Best Mirrors & Setting up repos
###############################################################################
"

sudo pacman -S reflector rsync --noconfirm
sudo cp -rf ~/lulz/pacman/* /etc/
sudo reflector -a 48 -c SE -f 5 -l 20 --sort rate --save /etc/pacman.d/mirrorlist
sudo pacman -Sy --noconfirm
sudo pacman -Syu --noconfirm

echo "
###############################################################################
# Installing essential software
###############################################################################
"

PKGS=(
'base-devel'
'firefox'

)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --needed --noconfirm --overwrite '*'
done


PKGS=(
'cmake'
'extra-cmake-modules'
'ninja'
'gperftools'
'python-setuptools'
'boost'
'boost-libs'
'bc'
'bison'
'flex'
'musl'
'meson'
'lz4'
'lzo'
'cpupower'
'llvm'
'llvm-libs'
'compiler-rt'
'clang'
'lld'
'lldb'
'polly'
'libunwind'
'openmp'
'libc++'
'libc++abi'
'htop'
'neofetch'
'jemalloc'
'zstd'
'pahole'
'paru'
'yay'
'cpio'
'zsh'
'zsh-completions'
'asp'
'micro'
'lz4'
'xorg-mkfontscale'
'xorg-fonts-encodings'
'xorg-font-util'
'xorg-server'
'xorg-server-devel'
'xorg-xinit'
'xorg-fonts-misc'
'imagemagick'
'w3m'
'wget'
'curl'
'alacritty'
'thunar'
'geany'
'geany-plugins'
'xfce4-settings'
'feh'
'rofi'
'polybar'
'irqbalance'
'dhcpcd'
'alacritty'
'sxhkd'
'worm'
'zram-generator'
'ananicy-cpp-git'
'cachyos-ananicy-rules'
'cachyos-rate-mirrors'
'wget'
'rxvt-unicode-truecolor-wide-glyphs'

)

for PKG in "${PKGS[@]}"; do
    echo "INSTALLING: ${PKG}"
    sudo pacman -S "$PKG" --needed --overwrite '*'
done

echo "
###############################################################################
# Applying Theme & Applying ZSH Configurations
###############################################################################
"

sleep 2
cd ~

sudo cp -rf ~/lulz/share/* /usr/share/
fc-cache -fv
sudo cp -rf ~/lulz/etc/* /etc/


echo "
###############################################################################
# Cloning essential repos
###############################################################################
"

mkdir git-repos
cd git-repos
git clone https://github.com/h0tc0d3/arch-packages.git
git clone https://github.com/cachyos/linux-cachyos.git
git clone https://github.com/frogging-family/nvidia-all.git
git clone https://github.com/rui314/mold
git clone https://github.com/ptr1337/dotfiles
git clone https://github.com/frogging-family/linux-tkg.git


echo "
###############################################################################
# MISC CONFIG
###############################################################################
"
sleep 2
cd ~
mkdir ~/build
cp ~/lulz/build.sh ~/build/

cp -rf ~/lulz/home/* ~/
cp -rf ~/lulz/home/. ~/
cp -rf ~/lulz/config/* ~/.config/
cp -rf ~/lulz/config/. ~/.config/



################################################################################
################################################################################


sudo pacman -S dkms nvidia-dkms nvidia-utils nvidia-settings --needed --noconfirm


xrdb ~/.Xresources
sudo pacman -Rc networkmanager --noconfirm
sudo pacman -Qtdq | sudo pacman -Rns -
chsh -s /usr/bin/zsh

#cd ~/lulz/pkg
#sudo pacman -U *.pkg.tar.zst --overwrite '*'
yay -S arch-silence-grub-theme-git update-grub powerpill python3-aur bauerbill zenpower3-dkms --noconfirm

sudo modprobe -r k10temp
sudo bash -c 'sudo echo -e "\n# replaced with zenpower\nblacklist k10temp" >> /etc/modprobe.d/blacklist.conf'
sudo modprobe zenpower
sudo systemctl enable ananicy
sudo systemctl disable NetworkManager.service
sudo systemctl enable irqbalance
#sudo systemctl enable uksmd
sudo systemctl enable haveged
sudo systemctl enable dhcpcd


sudo ln -sf /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
sudo ln -sf /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
sudo ln -sf /etc/fonts/conf.avail/10-hinting-full.conf /etc/fonts/conf.d
sudo sed "s,\#export FREETYPE_PROPERTIES=\"truetype\:interpreter-version=40\",export FREETYPE_PROPERTIES=\"truetype\:interpreter-version=40\",g" -i /etc/profile.d/freetype2.sh


sudo mkinitcpio -p linux
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo systemctl daemon-reload
sudo systemctl start /dev/zram0

echo "
###############################################################################
# Done
###############################################################################
"
sleep 3
