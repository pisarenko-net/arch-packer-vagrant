# (DEPRECATED) arch-packer-vagrant

**DEPRECATED**: [Superceded by arch-bootstrapper](https://github.com/pisarenko-net/arch-bootstrapper/blob/main/README.md)

Collection of configurations to build and provision functional Virtualbox images

The "packer" directory contains scripts and configuration files necessary to produce base ArchLinux image. The "vagrant" directory contains scripts and configuration files to produce complete preconfigured and usable VMs.

# Configure

Base image configuration is specified in `packer/arch-base.json`. Useful settings:
1. URL to the Arch installation ISO
2. Country for choosing the Arch mirror
3. Maximum size of the VM disk

VM-specific configuration is given in `vagrant/xxx/Vagrantfile`. Use `private` folder to bundle secrets, such as SSH keys or license files. See the `Vagrantfile` and corresponding setup scripts for more information.

# Usage

1. Build the base ArchLinux VirtualBox image using [Packer](packer.io):
```
$ ./packer.exe build -force arch-base.json
$ ./vagrant.exe box add output/arch_vagrant_base.box --name arch-base-YYYY-MM-DD --force  ## force is needed only when replacing
```
2. Edit and provision a particular [Vagrant](https://www.vagrantup.com/) configuration

# Extras

Get rid of VirtualBox menu and status bar:
```
VBoxManage setextradata global GUI/Customizations noMenuBar,noStatusBar
```

To re-enable menu and status bar:
```
VBoxManage setextradata global GUI/Customizations MenuBar,StatusBar
```
