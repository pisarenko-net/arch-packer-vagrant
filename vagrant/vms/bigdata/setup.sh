AS="/usr/bin/sudo -u sergey"

# install JDK
echo '==> Installing JDK'
/usr/bin/pacman -S --noconfirm jdk9-openjdk

# Reboot!
echo '==> Rebooting!'
/usr/bin/reboot
