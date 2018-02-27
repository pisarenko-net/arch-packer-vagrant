AS="/usr/bin/sudo -u sergey"

/usr/bin/touch /home/sergey/.zsh{rc,env}
/usr/bin/chown sergey:users /home/sergey/.zsh{rc,env}

echo '==> Installing and configuring Python'
/usr/bin/pacman -S --noconfirm python-virtualenv

echo '==> Installing and configuring Java'
/usr/bin/pacman -S --noconfirm jdk9-openjdk maven gradle

echo '==> Installing PyCharm'
cd /home/sergey
$AS /usr/bin/git clone https://aur.archlinux.org/pycharm-professional.git
cd /home/sergey/pycharm-professional
$AS /usr/bin/makepkg -si --noconfirm
cd ..
/usr/bin/rm -rf pycharm-professional

echo '==> Installing IntelliJ IDEA'
/usr/bin/pacman -S --noconfirm intellij-idea-community-edition

echo '==> Installing Android Studio'
cd /home/sergey
$AS /usr/bin/git clone https://aur.archlinux.org/android-studio.git
cd /home/sergey/android-studio
$AS /usr/bin/makepkg -si --noconfirm
cd ..
/usr/bin/rm -rf android-studio

echo '==> Installing Docker'
/usr/bin/pacman -S --noconfirm docker docker-compose
/usr/bin/systemctl enable docker.service

echo '==> Installing kubectl'
cd /home/sergey
$AS /usr/bin/git clone https://aur.archlinux.org/kubectl-bin.git
cd /home/sergey/kubectl-bin
$AS /usr/bin/makepkg -si --noconfirm
cd ..
/usr/bin/rm -rf kubectl-bin

echo '==> Configuring AWS'
/usr/bin/pacman -S --noconfirm aws-cli
if [ -d /vagrant/private/aws ]; then
	/usr/bin/cp -r /vagrant/private/aws /home/sergey/.aws
	/usr/bin/find /home/sergey/.aws -type f -exec chmod 600 {} \;
	/usr/bin/chown -R sergey:users /home/sergey/.aws
fi

echo '==> Copying VPN script'
if [ -f /vagrant/private/connect.py ]; then
	/usr/bin/cp /vagrant/private/connect.py /home/sergey/
	/usr/bin/chmod 644 /home/sergey/connect.py
	/usr/bin/chown -R sergey:users /home/sergey/connect.py
fi

echo '==> Configuring kubectl'
if [ -f /vagrant/private/kube_config ]; then
	/usr/bin/mkdir /home/sergey/.kube
	/usr/bin/cp /vagrant/private/kube_config /home/sergey/.kube/config
	/usr/bin/chmod 600 /home/sergey/.kube/config
	/usr/bin/chown -R sergey:users /home/sergey/.kube
fi

echo '==> Setting up Beekeeper-specific aliases'
/usr/bin/echo 'alias connect_vpn="python3 /home/sergey/connect.py"' >> /home/sergey/.zshrc
/usr/bin/echo 'alias dc="docker-compose"' >> /home/sergey/.zshrc
/usr/bin/echo 'alias ku="kubectl"' >> /home/sergey/.zshrc

echo '==> Setting up Beekeeper-specific environment variables'
/usr/bin/echo 'export COMPOSE_PROJECT_NAME="beekeeperstack"' >> /home/sergey/.zshenv
/usr/bin/echo 'export COMPOSE_FILE="docker-compose.stack.yml"' >> /home/sergey/.zshenv
/usr/bin/echo 'export PATH=~/.local/bin:/usr/bin/local:$PATH' >> /home/sergey/.zshenv

echo '==> Customizing sysctl'
/usr/bin/echo 'fs.inotify.max_user_watches = 524288' >> /etc/sysctl.d/99-sysctl.conf

echo '==> Rebooting!'
/usr/bin/reboot