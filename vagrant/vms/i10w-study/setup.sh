AS="/usr/bin/sudo -u sergey"

echo '==> Installing JDK'
/usr/bin/pacman -S --noconfirm jdk9-openjdk java-8-openjdk
/bin/archlinux-java set java-8-openjdk

echo '==> Installing IntelliJ IDEA'
/usr/bin/pacman -S --noconfirm intellij-idea-community-edition

echo '==> Checking out code repos'
cd /home/sergey
$AS /bin/git clone git@github.com:pisarenko-net/i10w-study.git github-repo
$AS /bin/git clone https://github.com/drseergio/practice.git previous-study

# Reboot!
echo '==> Rebooting!'
/usr/bin/reboot
