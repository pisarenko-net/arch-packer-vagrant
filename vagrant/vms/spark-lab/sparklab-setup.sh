AS="/usr/bin/sudo -u sergey"

SPARK_PACKAGE="spark-2.4.3-bin-hadoop2.7.tgz"
SPARK_PACKAGE_URL="http://mirror.easyname.ch/apache/spark/spark-2.4.3/$SPARK_PACKAGE"

echo '==> Allow home network passwordless login'
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2IGnU5uS1K0F2f0IE4p4hGGNNP0PGtIy6g/+SKpy8JN6X6H7TAZZ3jQA+2znVJtqX308OxG5V3BmUZtAaEa/DbfTITlY/b+wGt835Rw1S7BO51WH+TpD5orEx/TwSAHpedNgNh4YlDMHCILIEbWq7JBk+weJx6Ui3Tfj+ipHaQ1+JZwldzyxBqJlUp0MMNQiiFgfp3zftjIE76+Kb5mbomkxzZYi2ShVBBCP5jofGsaYLuL1kWWazj3ylNUBFOXdzulibPBRKS8zkUezOl+Rl9V2wokaQc4IxOmI1FOGVW3v4VmdbLwx5UFaMhyOPnDD0JaZSlokHHlSmcNghFImh drseergio@alabama' >> /home/sergey/.ssh/authorized_keys

echo '==> Installing Java'
/usr/bin/pacman -S --noconfirm jdk-openjdk

echo '==> Installing Scala'
/usr/bin/pacman -S --noconfirm scala

echo '==> Installing py4j'
/usr/bin/pacman -S --noconfirm python-pip
/usr/bin/pip3 install jupyter py4j

echo '==> Configuring Jupyter'
$AS /usr/bin/mkdir /home/sergey/.jupyter
$AS /usr/bin/cp /vagrant/configs/jupyter_notebook_config.py /home/sergey/.jupyter/

# Set-up Spark
cd /home/sergey
$AS /usr/bin/wget -q $SPARK_PACKAGE_URL
$AS /usr/bin/tar -zxf $SPARK_PACKAGE
$AS /usr/bin/rm $SPARK_PACKAGE
$AS /usr/bin/mv spark* spark/

$AS echo 'export SPARK_HOME="/home/sergey/spark"' >> /home/sergey/.zshenv
$AS echo 'export PATH=$SPARK_HOME:$PATH' >> /home/sergey/.zshenv
$AS echo 'export PYTHONPATH=$SPARK_HOME/python:$PYTHONPATH' >> /home/sergey/.zshenv
$AS echo 'export PYSPARK_DRIVER_PYTHON="jupyter"' >> /home/sergey/.zshenv
$AS echo 'export PYSPARK_DRIVER_PYTHON_OPTS="notebook"' >> /home/sergey/.zshenv
$AS echo 'export PYSPARK_PYTHON=python3' >> /home/sergey/.zshenv

/usr/bin/chmod 777 /home/sergey/spark
/usr/bin/chmod 777 /home/sergey/spark/python
/usr/bin/chmod 777 /home/sergey/spark/python/pyspark
/usr/bin/chmod 777 /home/sergey/spark

# Reboot!
echo '==> Rebooting!'
/usr/bin/reboot
