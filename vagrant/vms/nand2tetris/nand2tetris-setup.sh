AS="/usr/bin/sudo -u sergey"

# install JDK
echo '==> Installing JDK'
/usr/bin/pacman -S --noconfirm jdk9-openjdk

# check out repository
echo '==> Checking out repository'
cd /home/sergey
$AS /usr/bin/sh -c '/usr/bin/ssh-keyscan github.com >> /home/sergey/.ssh/known_hosts'
$AS /usr/bin/git clone git@github.com:pisarenko-net/nand2tetris.git

# Reboot!
echo '==> Rebooting!'
/usr/bin/reboot