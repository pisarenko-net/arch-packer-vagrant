AS="/usr/bin/sudo -u sergey"

echo '==> Installing Docker'
/usr/bin/pacman -S --noconfirm docker docker-compose
/usr/bin/systemctl enable docker.service
/bin/usermod -aG docker sergey

echo '==> Installing JDK'
/usr/bin/pacman -S --noconfirm java-8-openjdk

echo '==> Installing IntelliJ IDEA'
/usr/bin/pacman -S --noconfirm intellij-idea-community-edition

# Reboot!
echo '==> Rebooting!'
/usr/bin/reboot
