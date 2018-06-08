AS="/usr/bin/sudo -u sergey"

echo '==> Installing CLI tools'
/usr/bin/pacman -S --noconfirm jq

echo '==> Installing and configuring Python'
/usr/bin/pacman -S --noconfirm python-virtualenv python-pip

echo '==> Installing and configuring Java'
/usr/bin/pacman -S --noconfirm jdk9-openjdk jdk8-openjdk maven gradle
/bin/archlinux-java set java-8-openjdk

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

echo '==> Installing wrk (load balance tool)'
cd /home/sergey
$AS /usr/bin/git clone https://aur.archlinux.org/wrk.git
cd /home/sergey/wrk
$AS /usr/bin/makepkg -si --noconfirm
cd ..
/usr/bin/rm -rf wrk

echo '==> Installing Postman'
cd /home/sergey
$AS /usr/bin/git clone https://aur.archlinux.org/ttf-opensans.git
cd /home/sergey/ttf-opensans
$AS /usr/bin/makepkg -si --noconfirm
cd ..
/usr/bin/rm -rf ttf-opensans
$AS /usr/bin/git clone https://aur.archlinux.org/postman.git
cd /home/sergey/postman
$AS /usr/bin/makepkg -si --noconfirm
cd ..
/usr/bin/rm -rf postman

echo '==> Installing Docker'
/usr/bin/pacman -S --noconfirm docker docker-compose
/usr/bin/systemctl enable docker.service
/bin/usermod -aG docker sergey

echo '==> Installing kubectl'
cd /home/sergey
/bin/curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.5.8/bin/linux/amd64/kubectl
/bin/chmod +x kubectl
/bin/mv kubectl /bin

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

echo '==> Copying API access'
pacman -S --noconfirm openvpn
pip install tabulate
$AS /usr/bin/mkdir /home/sergey/.bkpr-ims
$AS /usr/bin/cp /vagrant/private/api.token /home/sergey/.bkpr-ims

echo '==> Customizing sysctl'
/usr/bin/echo 'fs.inotify.max_user_watches = 524288' >> /etc/sysctl.d/99-sysctl.conf
/usr/bin/echo 'vm.max_map_count = 262144' >> /etc/sysctl.d/99-sysctl.conf

echo '==> Setting the wallpaper'
$AS /usr/bin/cp /vagrant/configs/xfce4-desktop.xml /home/sergey/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml

echo '==> Checking out code repos'
cd /home/sergey
$AS /bin/git clone git@github.com:beekpr/beekeeper-stack.git beekeeper-stack
$AS /bin/virtualenv -p /bin/python2.7 beekeeper-python
source beekeeper-python/bin/activate
$AS /home/sergey/beekeeper-python/bin/pip install jinja2

echo '==> Rebooting!'
/usr/bin/reboot
