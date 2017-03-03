#Local Zune Firmware Server for Recovery
This project Provides a host for the Zune Desktop app to fetch the firmware for a device recovery which was taken offline
after Microsoft discontinued the Zune programme.

It is based on a Vagrant/Ansible machine running Ubuntu to serve the files on a URL which the Zune Desktop Software expects as a resource.

## 0. Issue
Installing the Zune Firmware fails with the error codes C00D133C (80190194).

## 1. Preparations
Please install:
* VirtualBox: https://www.virtualbox.org/
* VirtualBox Extension Pack (see above)
* Vagrant: https://www.vagrantup.com/downloads.html
* Zune Desktop Software (Version 4.8 recommended): https://www.microsoft.com/de-de/download/details.aspx?id=27163

## 2. Getting the setup ready
* Add write permissions to the directory for all users: C:\HashiCorp\Vagrant
* Run: `vagrant plugin install vagrant-hostmanager`
* and: `vagrant plugin install vagrant-triggers`

## 3. Adding the Firmware files
* Firmware files are not inside this package as they belong to Microsft.
* Download these files from http://go.microsoft.com/fwlink/?LinkId=185560
* Download the program "LesMSIerables" from http://blogs.pingpoet.com/overflow/archive/2005/11/16/14995.aspx and extract the archive.
* Launch `lessmsi.exe` and extract extract the *.cab files to the `htdocs\firmware\v4_5` directory of this project.

## 4. Starting the recovery
* Open a command prompt window and cd to the project's root directory (where Vagrantfile is located).
* Buld this virtual machine. This can take a while when starting it the first time. Type:
`vagrant up`
* The machine will be booted automatically.
* You can test whether the host is available by opening http://resources.zune.net in your web browser.
* Connect your device. Zune Software should start up automatically and be able to load the firmware from this project's machine.

## When you are done
you may delete the virtual machine by typing `vagrant destroy`.

Good luck!

## Credits
* Based on the OXID Base VM https://github.com/OXID-eSales/oxvm_base (dropped anything but Apache Webserver)
* Thanks to Jazzfan80 https://www.reddit.com/r/Zune/comments/4djt89/psa_the_zune_firmwares_are_able_to_be_installed/?st=izue227o&sh=dc6a3c80
