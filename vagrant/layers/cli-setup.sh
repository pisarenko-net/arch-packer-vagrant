# enable time sync
echo "==> Enable time sync"
/usr/bin/timedatectl set-ntp true

# synchronize package database
echo "==> Refreshing pacman"
/usr/bin/pacman -Syu --noconfirm

# install tools
echo "==> Installing tools"
/usr/bin/pacman -S --noconfirm git htop net-tools tcpdump parted netcat tmux hwinfo zsh mc gnupg zip unrar wget linux-headers lsof dnsutils

# set nvim as default editor
echo "==> Setting default text editor"
/usr/bin/ln -sf /usr/bin/nvim /usr/bin/vi
/usr/bin/echo 'EDITOR=nvim' >> /etc/environment
/usr/bin/echo 'VISUAL=nvim' >> /etc/environment

# enable sudo for all members of group wheel
echo "==> Enable passwordless sudo for wheel group"
sed -i 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

# create user 'sergey'
echo "==> Create user 'sergey'"
/usr/bin/groupadd -r autologin
/usr/bin/useradd -m -g users -G wheel,storage,power,autologin,vagrant -s /bin/zsh sergey
echo "sergey:test" | chpasswd
AS="/usr/bin/sudo -u sergey"
cd /home/sergey

# enable auto mount
#echo '==> Enabling share auto mount'
#echo "vagrant  /vagrant  vboxsf uid=1000,gid=1000,rw,dmode=775,fmode=664,noauto,x-systemd.automount" >> /etc/fstab
#echo "shared  /shared  vboxsf uid=1000,gid=1000,rw,dmode=775,fmode=664,noauto,x-systemd.automount" >> /etc/fstab

# set git configuration
echo "==> Set git configuration"
$AS /usr/bin/git config --global user.email "${EMAIL}"
$AS /usr/bin/git config --global user.name "${FULL_NAME}"

# customize zsh
echo "==> Configure/customize shell"
$AS /usr/bin/rm .bash*
$AS /usr/bin/mkdir /home/sergey/.cache
$AS /usr/bin/git clone https://aur.archlinux.org/oh-my-zsh-git.git
cd oh-my-zsh-git
$AS /usr/bin/makepkg -si --noconfirm
$AS /usr/bin/cp /usr/share/oh-my-zsh/zshrc /home/sergey/.zshrc
cd ..
/usr/bin/rm -rf oh-my-zsh-git
/usr/bin/touch /home/sergey/.zsh{rc,env}
/usr/bin/chown sergey:users /home/sergey/.zsh{rc,env}
/usr/bin/echo 'unsetopt share_history' >> /home/sergey/.zshenv
/usr/bin/echo 'export HISTFILE="$HOME/.zsh_history"' >> /home/sergey/.zshenv
/usr/bin/echo 'export HISTSIZE=10000000' >> /home/sergey/.zshenv
/usr/bin/echo 'export SAVEHIST=10000000' >> /home/sergey/.zshenv

# set-up SSH keys
echo '==> Configuring SSH keys'
if [ -f /vagrant/private/id_rsa ]; then
	$AS /usr/bin/mkdir /home/sergey/.ssh
	$AS /usr/bin/cp /vagrant/private/id_rsa /home/sergey/.ssh
	$AS /usr/bin/cp /vagrant/private/id_rsa.pub /home/sergey/.ssh
	$AS /usr/bin/chmod 400 /home/sergey/.ssh/id_rsa
else
	$AS /usr/bin/ssh-keygen -t rsa -f /home/sergey/.ssh/id_rsa -q -P ""
fi
$AS sh -c 'echo "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAqmQw7RdwQe6BKJE8dlp4u3wpPBFNRtGVoolcTjcc7I7aljh6lvK2EKc6nf73Fe418mjWbQFsADk3c0YTk1tkTqATu0wlP9BFEu6eogoT2qwEf8XE2+hsZiYzbJvYXArmvYVeowgkpuLNw3OuHJ1WL9mftmtnFmp3W2grih19H8fFBybYKJBFyS13Zbsui7hkjPbkroHh0OpofwhN4jggw5YffuJofKdGNTv08V7NdW+8wov9/3QCd65Tslwi0tYKPflzDTZW3HX3JVpCJ8VDr6zxlOgOCSW6ds9ATfpXaItTW9kRgyCQ+8jwlXnPBfMQioVK9+tVxqmXLY+6/ciH1w== rsa-key-20180116" >> /home/sergey/.ssh/authorized_keys'
$AS sh -c 'echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2IGnU5uS1K0F2f0IE4p4hGGNNP0PGtIy6g/+SKpy8JN6X6H7TAZZ3jQA+2znVJtqX308OxG5V3BmUZtAaEa/DbfTITlY/b+wGt835Rw1S7BO51WH+TpD5orEx/TwSAHpedNgNh4YlDMHCILIEbWq7JBk+weJx6Ui3Tfj+ipHaQ1+JZwldzyxBqJlUp0MMNQiiFgfp3zftjIE76+Kb5mbomkxzZYi2ShVBBCP5jofGsaYLuL1kWWazj3ylNUBFOXdzulibPBRKS8zkUezOl+Rl9V2wokaQc4IxOmI1FOGVW3v4VmdbLwx5UFaMhyOPnDD0JaZSlokHHlSmcNghFImh drseergio@alabama" >> /home/sergey/.ssh/authorized_keys'
$AS sh -c 'echo "github.com,192.30.253.113 ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==" >> /home/sergey/.ssh/known_hosts'

# set-up PGP
echo '==> Configuring PGP'
if [ -d /vagrant/private/gnupg ]; then
	/usr/bin/cp -r /vagrant/private/gnupg /home/sergey/.gnupg
	/usr/bin/find /home/sergey/.gnupg -type f -exec chmod 600 {} \;
	/usr/bin/find /home/sergey/.gnupg -type d -exec chmod 700 {} \;
	/usr/bin/chown -R sergey:users /home/sergey/.gnupg
fi

# custom binaries
echo '==> Installing custom binaries into /usr/bin/local/'
if [ -d /vagrant/binaries ]; then
	/usr/bin/mkdir -p /usr/bin/local/
	/usr/bin/cp /vagrant/binaries/* /usr/bin/local/
	/usr/bin/chmod +x /usr/bin/local/*
fi

# custom configs
echo '==> Setting up custom settings'
cd /home/sergey
$AS /usr/bin/mkdir .config
$AS /usr/bin/cp -r /tmp/configs/mc .config/
$AS /usr/bin/mkdir .config/nvim
$AS /usr/bin/cp -r /tmp/configs/nvim .config/nvim/init.vim
