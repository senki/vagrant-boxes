# lamp-base-php55
Basic LAMP Vagrant machine with PHP v5.5

## Included SW
- Ubuntu Trusty x64 (14.04 LTS)
- Apache 2.4.7 
- MySQL 5.5.46
- PHP 5.5.9
- PHPMyAdmin 4.2.3

## Usage
1. Download/clone repository
2. `cd` to folder
3. type `vagrant up` (wait for virtual machine completely booted/provisioned)
4. go to [192.168.33.15](http://192.168.33.15)  
5. Enjoy!

## Deploy to your vagrant as new box 
Run `./deploy.sh`. (Thats it!) :)

## Pre-requirements on OS X
- git (via homebrew: `brew install git`)
    - [homebrew](http://brew.sh)
    - [SourceTree](https://www.sourcetreeapp.com) (optional)
- [Vagrant](https://www.vagrantup.com)
    - [vagrant-reload](https://github.com/aidanns/vagrant-reload)
    - [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest)  
    - [VirtualBox](https://www.virtualbox.org)

