AS="/usr/bin/sudo -u sergey"

# install desktop environment
echo '==> Installing desktop environment'
/usr/bin/pacman -S --noconfirm xorg-server xorg-xinit lxdm xfce4

# install virtualbox modules for X
echo '==> Intalling virtualbox Xorg modules'
/usr/bin/pacman -R --noconfirm virtualbox-guest-utils-nox
/usr/bin/pacman -S --noconfirm virtualbox-guest-utils
$AS echo "/usr/bin/VBoxClient-all" > /home/sergey/.xinitrc

# configure desktop manager
echo '==> Enabling desktop manager'
/usr/bin/sed -i 's/# autologin=dgod/autologin=sergey/' /etc/lxdm/lxdm.conf
/usr/bin/sed -i 's/# session=\/usr\/bin\/startlxde/session=\/usr\/bin\/startxfce4/' /etc/lxdm/lxdm.conf
/usr/bin/systemctl enable lxdm.service

# install fonts
echo '==> Installing fonts'
/usr/bin/pacman -S --noconfirm noto-fonts ttf-roboto ttf-dejavu adobe-source-code-pro-fonts ttf-ubuntu-font-family

# install tools
echo '==> Installing useful tools'
/usr/bin/pacman -S --noconfirm terminator meld parcellite thunar-archive-plugin gvfs tk

# install albert
echo '==> Installing albert (AUR)'
cd /home/sergey
$AS /usr/bin/git clone https://aur.archlinux.org/albert-lite.git
cd albert-lite
$AS /usr/bin/makepkg -si --noconfirm
cd ..
$AS /usr/bin/rm -rf albert-lite

# install sublime
echo '==> Installing sublime (AUR)'
$AS /usr/bin/git clone https://aur.archlinux.org/sublime-text-dev.git
cd sublime-text-dev
$AS /usr/bin/makepkg -si --noconfirm
cd ..
$AS /usr/bin/rm -rf sublime-text-dev

# install Google Chrome
echo '==> Installing Google Chrome (AUR)'
cd /home/sergey
$AS /usr/bin/git clone https://aur.archlinux.org/google-chrome.git
cd google-chrome
$AS /usr/bin/makepkg -si --noconfirm
cd ..
$AS /usr/bin/rm -rf google-chrome

# customize XFCE
echo '==> Customizing XFCE'
cd /home/sergey
$AS /usr/bin/mkdir .config
$AS /usr/bin/cp -r /vagrant/configs/xfce4 .config/
$AS /usr/bin/cp -r /vagrant/configs/terminator .config/
$AS /usr/bin/cp -r /vagrant/configs/albert .config/
$AS /usr/bin/cp -r /vagrant/configs/autostart .config/
/usr/bin/chown -R sergey:users .config

# install Sublime license, when available
if [ -f /vagrant/private/License.sublime_license ]; then
	echo '==> Installing Sublime license'
	$AS /usr/bin/mkdir -p .config/sublime-text-3/Local/
	$AS /usr/bin/cp /vagrant/private/License.sublime_license .config/sublime-text-3/Local/
fi
