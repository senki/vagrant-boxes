# vagrant-lamp-base
Basic LAMP Vagrant machines.  
Currently only with VirtualBox provider.

## senki/precise64
- Ubuntu Precise x64 (12.04 LTS)
- Apache 2.2.22 
- MySQL 5.5.46
- PHP  5.4.45
- PHPMyAdmin 4.2.3

## senki/trusty64
- Ubuntu Trusty x64 (14.04 LTS)
- Apache 2.4.7 
- MySQL 5.5.46
- PHP 5.5.9
- PHPMyAdmin 4.2.3

## Usage
1. Download/clone repository
2. `cd` to folder
3. type `build.sh` ...wait for it
4. You have a `senki/precise64` & `senki/trusty64` machine imported to vagrant
5. check with `vagrant box list`

## Pre-requirements on OS X
- git (recommended via homebrew: `brew install git`)
    - [homebrew](http://brew.sh)
    - [SourceTree](https://www.sourcetreeapp.com) (optional GUI for git)
- [Vagrant](https://www.vagrantup.com)
    - [VirtualBox](https://www.virtualbox.org)

Copyright (c) 2015 Csaba Maulis  
Licence: [MIT License](LICENSE)
