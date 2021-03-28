#!/usr/bin/env bash

# stop on errors
set -eu

DISK='/dev/sda'

FQDN='arch.bethania'
KEYMAP='us'
LANGUAGE='en_US.UTF-8'
PASSWORD=$(/usr/bin/openssl passwd -crypt 'vagrant')
TIMEZONE='Europe/Zurich'

CONFIG_SCRIPT='/usr/local/bin/arch-config.sh'
BOOT_PARTITION="${DISK}1"
ROOT_PARTITION="${DISK}2"
TARGET_DIR='/mnt'
MIRRORLIST="https://www.archlinux.org/mirrorlist/?country=${COUNTRY}&protocol=http&protocol=https&ip_version=4&use_mirror_status=on"

echo "==> Create GPT partition table on ${DISK}"
/usr/bin/sgdisk -og ${DISK}

echo "==> Destroying magic strings and signatures on ${DISK}"
/usr/bin/dd if=/dev/zero of=${DISK} bs=512 count=2048
/usr/bin/wipefs --all ${DISK}

echo "==> Creating /boot EFI partition on ${DISK}"
/usr/bin/sgdisk -n 1:2048:2098175 -c 1:"EFI boot partition" -t 1:ef00 ${DISK}

echo "==> Creating /root partition on ${DISK}"
ENDSECTOR=`/usr/bin/sgdisk -E ${DISK}`
/usr/bin/sgdisk -n 2:2098176:$ENDSECTOR -c 2:"Linux root partition" -t 2:8300 ${DISK}

echo '==> Creating /boot filesystem (FAT32)'
/usr/bin/mkfs.fat -F32 $BOOT_PARTITION

echo '==> Creating /root filesystem (btrfs)'
/usr/bin/mkfs.btrfs $ROOT_PARTITION

echo "==> Mounting ${ROOT_PARTITION} to ${TARGET_DIR}"
/usr/bin/mount ${ROOT_PARTITION} ${TARGET_DIR}
echo "==> Mounting ${BOOT_PARTITION} to ${TARGET_DIR}/boot"
/usr/bin/mkdir ${TARGET_DIR}/boot
/usr/bin/mount ${BOOT_PARTITION} ${TARGET_DIR}/boot

echo "==> Setting local mirror"
curl -L -s "$MIRRORLIST" |  sed 's/^#Server/Server/' > /etc/pacman.d/mirrorlist

echo '==> Bootstrapping the base installation'
/usr/bin/pacstrap ${TARGET_DIR} base base-devel lvm2 linux linux-firmware btrfs-progs netctl neovim dhcpcd openssh grub-efi-x86_64 efibootmgr net-tools intel-ucode wget git

echo '==> Generating the filesystem table'
/usr/bin/genfstab -U ${TARGET_DIR} >> "${TARGET_DIR}/etc/fstab"

echo '==> Installing GRUB'
/usr/bin/sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=0/' "${TARGET_DIR}/etc/default/grub"
/usr/bin/sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=".*"/GRUB_CMDLINE_LINUX_DEFAULT="quiet video=1360x768"/' "${TARGET_DIR}/etc/default/grub"

echo '==> Generating the system configuration script'
/usr/bin/install --mode=0755 /dev/null "${TARGET_DIR}${CONFIG_SCRIPT}"

cat <<-EOF > "${TARGET_DIR}${CONFIG_SCRIPT}"
# GRUB bootloader installation
/usr/bin/grub-install --target=x86_64-efi --efi-directory=/boot
/usr/bin/grub-mkconfig -o /boot/grub/grub.cfg
/usr/bin/mkdir /boot/EFI/BOOT
/usr/bin/cp /boot/EFI/arch/grubx64.efi /boot/EFI/BOOT/bootx64.efi

echo '${FQDN}' > /etc/hostname
/usr/bin/ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
echo 'KEYMAP=${KEYMAP}' > /etc/vconsole.conf
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
/usr/bin/sed -i 's/#${LANGUAGE}/${LANGUAGE}/' /etc/locale.gen
/usr/bin/locale-gen
/usr/bin/usermod --password ${PASSWORD} root
# https://wiki.archlinux.org/index.php/Network_Configuration#Device_names
/usr/bin/ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules
/usr/bin/ln -s '/usr/lib/systemd/system/dhcpcd@.service' '/etc/systemd/system/multi-user.target.wants/dhcpcd@eth0.service'
/usr/bin/sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
/usr/bin/systemctl enable sshd.service

# Vagrant-specific configuration
/usr/bin/useradd --password ${PASSWORD} --comment 'Vagrant User' --create-home --user-group vagrant
echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10_vagrant
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10_vagrant
/usr/bin/chmod 0440 /etc/sudoers.d/10_vagrant
/usr/bin/install --directory --owner=vagrant --group=vagrant --mode=0700 /home/vagrant/.ssh
/usr/bin/curl --output /home/vagrant/.ssh/authorized_keys --location https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
/usr/bin/chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
/usr/bin/chmod 0600 /home/vagrant/.ssh/authorized_keys


# Clean the pacman cache.
/usr/bin/yes | /usr/bin/pacman -Scc
EOF

echo '==> Entering chroot and configuring system'
/usr/bin/arch-chroot ${TARGET_DIR} ${CONFIG_SCRIPT}
rm "${TARGET_DIR}${CONFIG_SCRIPT}"

echo '==> Installation complete!'
/usr/bin/sleep 3
/usr/bin/umount ${TARGET_DIR}/boot
/usr/bin/umount ${TARGET_DIR}
