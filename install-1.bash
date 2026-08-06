#!/usr/bin/env bash

set -eo pipefail

sc () {
  sleep 1
  clear
}

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

echo 'Setting larger font..'
setfont ter-132b
sc

echo 'Refreshing package keyring..'
timedatectl set-timezone Asia/Karachi
pacman -Sy --noconfirm archlinux-keyring util-linux
sc

echo 'OK. We begin..'
sc

echo 'Deleting old partitions in 5 seconds!!'
for i in {5..1}; do
  echo "$i..."
  sleep 1
done

echo 'Wiping disk signatures..'
wipefs -a /dev/nvme0n1
sync; sync
sc

echo 'Creating Partitions..'
sfdisk --color /dev/nvme0n1 << EOF
label: gpt
size=2G
size=36500M
size=8G
size=2G, type=swap
size=+
EOF
sync; sync
partprobe /dev/nvme0n1
udevadm settle
sc

echo 'Formatting Partitions..'
mkfs.fat -F32 -n BOOT "/dev/nvme0n1p1"
mkfs.ext4 -L root     "/dev/nvme0n1p2"
mkfs.ext4 -L var      "/dev/nvme0n1p3"
mkswap -L swap        "/dev/nvme0n1p4"
mkfs.xfs -f -L home   "/dev/nvme0n1p5"
sync; sync
udevadm settle
sc

echo 'Mounting Filesystems..'
mount /dev/nvme0n1p2 /mnt
mount --mkdir /dev/nvme0n1p1 /mnt/boot
mount --mkdir /dev/nvme0n1p3 /mnt/var
mount --mkdir /dev/nvme0n1p5 /mnt/home
swapon /dev/nvme0n1p4
sync; sync
udevadm settle
sc

echo 'Disk preparation complete!'
lsblk /dev/nvme0n1
sleep 2
sc

echo 'Setting up mirrorlist..'
echo 'Server = https://mirror.sg.cdn-perfprod.com/archlinux/$repo/os/$arch' > templist
echo 'Server = https://sg.mirrors.cicku.me/archlinux/$repo/os/$arch' >> templist
cat templist /etc/pacman.d/mirrorlist > newlist
rm templist
mv newlist /etc/pacman.d/mirrorlist
sc

echo 'Installing base-system..'

# Base system
pacstrap -K /mnt base linux-zen linux-lts

# Firmware
pacstrap /mnt linux-firmware-intel intel-ucode sof-firmware

# Development tools
pacstrap /mnt base-devel git linux-zen-headers

# Audio and Video
pacstrap /mnt pipewire wireplumber pipewire-audio pipewire-pulse pipewire-jack pipewire-alsa pipewire-v4l2

# System Utilities
pacstrap /mnt e2fsprogs xfsprogs dosfstools android-udev efibootmgr polkit

# User Utilities
pacstrap /mnt neovim brightnessctl networkmanager man-db man-pages texinfo wiremix android-tools \
  less noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-liberation ttf-dejavu ttf-ibmplex-mono-nerd \
  ttf-sharetech-mono-nerd wl-clipboard

# Graphical Environment (sway based desktop)
pacstrap /mnt firefox sway swaylock swayidle swaybg swayimg swaync wmenu foot polkit-gnome slurp wf-recorder \
  grim nwg-displays

sync; sync
sc

echo 'Creating fstab file..'
genfstab -L /mnt >> /mnt/etc/fstab
sc
