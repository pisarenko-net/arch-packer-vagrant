AS="/usr/bin/sudo -u sergey"

echo '==> Installing Docker'
/usr/bin/pacman -S --noconfirm docker docker-compose
/usr/bin/systemctl enable docker.service
/bin/usermod -aG docker sergey

echo '==> Installing JDK'
/usr/bin/pacman -S --noconfirm jdk9-openjdk java-8-openjdk
/bin/archlinux-java set java-8-openjdk

echo '==> Installing IntelliJ IDEA'
/usr/bin/pacman -S --noconfirm intellij-idea-community-edition

echo '==> Checking out code repos'
cd /home/sergey
$AS /bin/git clone git@github.com:pisarenko-net/coursera-yandex-big-data.git

# delete mount.vboxsf binary
echo '==> Deleting mount.vboxsf binary'
/usr/bin/rm /usr/bin/mount.vboxsf

# Reboot!
echo '==> Rebooting!'
/usr/bin/reboot