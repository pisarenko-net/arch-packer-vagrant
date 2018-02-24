# arch-packer-vagrant
Collection of configurations to build and provision functional Virtualbox images

The "packer" directory contains scripts and configuration files necessary to produce base ArchLinux image. The "vagrant" directory contains scripts and configuration files to produce complete preconfigured and usable VMs.

# Usage

1. Build the base ArchLinux VirtualBox image using [Packer](packer.io):
```
$ ./packer.exe build -force arch-base.json
$ ./vagrant.exe box add output/arch_vagrant_base.box --name arch-base --force
```
2. Edit and provision a particular [Vagrant](https://www.vagrantup.com/) configuration
