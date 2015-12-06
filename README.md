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

## usage
- Download/clone repository
- `cd` to folder

### build
1. type `build.sh` ...wait for finish
2. You have a `senki/precise64` & `senki/trusty64` machine imported to vagrant
3. check with `vagrant box list`

### test
1. type `test.sh` ...wait for finish
2. You have a `lamp-precise-test.local` & `lamp-trusty-test-local` machine up & running

## pre-requirements on OS X
- git (recommended via homebrew: `brew install git`)
    - [homebrew](http://brew.sh)
    - [SourceTree](https://www.sourcetreeapp.com) (optional GUI for git)
- [Vagrant](https://www.vagrantup.com)
    - [vagrant-reload](https://github.com/aidanns/vagrant-reload)
    - [VirtualBox](https://www.virtualbox.org)

## version history
For details, see git  

- 1.0       2015.11.27
- 1.0.1     2015.12.02
- 1.0.3     2015.12.06

## LICENSE

Copyright (c) 2015 Csaba Maulis  
Licence: [MIT License](LICENSE)
