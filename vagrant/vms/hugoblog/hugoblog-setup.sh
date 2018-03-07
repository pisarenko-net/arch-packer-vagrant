AS="/usr/bin/sudo -u sergey"

# install hugo
pacman -S --noconfirm hugo

# check out repository
echo '==> Checking out repository'
cd /home/sergey
$AS /usr/bin/git clone git@github.com:drseergio/drseergio.github.com.git hugoblog
cd /home/sergey/hugoblog
$AS git checkout source
$AS git worktree add -B master public origin/master

# Reboot!
echo '==> Rebooting!'
/usr/bin/reboot