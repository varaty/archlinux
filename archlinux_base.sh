#!/bin/sh

export disk='/dev/sdb'
export boot='+1G'
export swap='+4G'
export root='+32G'
export kernel='linux linux-lts'
export microcode='intel-ucode amd-ucode'
export region='Asia'
export city='Kolkata'
export locale='en_US.UTF-8 UTF-8'
export language='en_US.UTF-8'
export keyboard='us'
export hostname='archlinux'
export username='ht'

ping -c 5 archlinux.org &&

sgdisk -go $disk &&
sgdisk -n 1:0:$boot -t 1:ef00 $disk &&
sgdisk -n 2:0:$swap -t 2:8200 $disk &&
sgdisk -n 3:0:$root -t 3:8300 $disk &&
sgdisk -n 4:0:0 -t 4:8300 $disk &&
sgdisk -p $disk &&

mkfs.fat -F 32 $disk\1 &&
mkswap $disk\2 &&
mkfs.ext4 $disk\3 &&
mkfs.ext4 $disk\4 &&

mount --mkdir $disk\1 /mnt/boot &&
swapon $disk\2 &&
mount $disk\3 /mnt &&
mount --mkdir $disk\4 /mnt/home &&

echo -e "--save /etc/pacman.d/mirrorlist\n--protocol https\n--latest 20\n--country India\n--sort rate" > /etc/xdg/reflector/reflector.conf &&
systemctl start reflector &&

pacstrap -K /mnt base base-devel $kernel linux-firmware sof-firmware networkmanager nano man-db grub efibootmgr $microcode &&

genfstab -U /mnt >> /mnt/etc/fstab &&
cat /mnt/etc/fstab &&

arch-chroot /mnt ln -sf /usr/share/zoneinfo/$region/$city /etc/localtime &&
arch-chroot /mnt hwclock --systohc &&
arch-chroot /mnt systemctl enable systemd-timesyncd &&

arch-chroot /mnt echo "$locale" >> /etc/locale.gen &&
arch-chroot /mnt locale-gen &&
arch-chroot /mnt echo "LANG=$language" > /etc/locale.conf &&
arch-chroot /mnt echo "KEYMAP=$keyboard" > /etc/vconsole.conf &&

arch-chroot /mnt echo "$hostname" > /etc/hostname &&
arch-chroot /mnt systemctl enable NetworkManager &&

arch-chroot /mnt echo -e "\n%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers &&

arch-chroot /mnt useradd -m -G wheel $username &&
clear && echo -e "Set the password for user $username.\n" &&
arch-chroot /mnt passwd $username &&

arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --removable &&
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg &&

umount -R /mnt &&
clear && echo "Restarting the machine..." &&
sleep 5 && reboot
