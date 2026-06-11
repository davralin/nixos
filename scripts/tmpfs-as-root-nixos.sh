#!/usr/bin/env bash
DISK=/dev/disk/by-id/
ROOTSIZE=100GiB
echo "R U SURE?!"
sleep 10s

echo "Unmount drives"
for i in /mnt/*; do
  umount $i
done
umount /mnt/etc/nixos
umount /mnt/var/log
umount /mnt

echo "Reinit drive"
parted $DISK -- mklabel gpt
sleep 1s

echo "Create boot-part"
parted $DISK -- mkpart ESP fat32 1MiB 512MiB
parted $DISK -- set 1 boot on
sleep 1s
mkfs.vfat -n BOOT $DISK-part1

echo "Create /nix"
sleep 1s
parted $DISK -- mkpart primary ext4 512MiB $ROOTSIZE
sleep 1s
mkfs.ext4 -m0 -L nixstore $DISK-part2

echo "Mounting the things"
mount -t tmpfs none /mnt
mkdir -p /mnt/{boot,nix,etc/nixos,var/log,opt}
mount $DISK-part1 /mnt/boot
mount $DISK-part2 /mnt/nix
mkdir -p /mnt/nix/persist/{etc/nixos,etc/ssh,etc/NetworkManager/system-connections,var/log,var/lib/acme,var/lib/bluetooth,var/lib/dnsmasq,opt}
mount -o bind /mnt/nix/persist/etc/nixos /mnt/etc/nixos
mount -o bind /mnt/nix/persist/var/log /mnt/var/log
mount -o bind /mnt/nix/persist/opt /mnt/opt

echo "Creating nixos-config"
nixos-generate-config --root /mnt
