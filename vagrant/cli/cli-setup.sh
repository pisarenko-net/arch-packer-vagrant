# enable time sync
echo "==> Enable time sync"
/usr/bin/timedatectl set-ntp true

# install tools
echo "==> Installing tools"
/usr/bin/pacman -S --noconfirm git htop net-tools tcpdump parted netcat tmux hwinfo zsh mc

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
/usr/bin/useradd -m -g users -G wheel,storage,power,vboxsf,autologin,vagrant -s /bin/zsh sergey
echo "sergey:test" | chpasswd
AS="/usr/bin/sudo -u sergey"
cd /home/sergey

# enable auto mount
echo '==> Enabling share auto mount'
echo "vagrant  /vagrant  vboxsf uid=1000,gid=1000,rw,dmode=775,fmode=664,noauto,x-systemd.automount" >> /etc/fstab
echo "shared  /shared  vboxsf uid=1000,gid=1000,rw,dmode=775,fmode=664,noauto,x-systemd.automount" >> /etc/fstab

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