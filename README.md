# vagrant-boxes

Create Basic Ubuntu LAMP Vagrant boxes.  
Currently only with VirtualBox provider.

>WIP – Currently `senki/[boxes]` not available online for downloads.

## Features

- Install user configurable VirtualBox additions
- Automatically backup `/var/lib/mysql/` dir on guest shutdown to `vagrant/db/mysql-$NOW.tar.gz`
- Manually backup or restore `/var/lib/mysql/` dir with  `/etc/init.d/mysqlbackuphandler.sh`
- Provision 'check' files: `/var/provision/*`, to safely re-provison boxes.
- Provision logs:
  - guest: `/var/log/provision.log`
  - host: `vagrant/log/$HOST_NAME-$NOW.log`
- Box version string saved in guest's `/var/provision/version` file
- Installed utilities: ruby, htop, tree, multitail


## Boxes

1. **senki/precise**
  - Ubuntu Precise x64 (12.04 LTS)
  - Apache 2.2.22
  - MySQL 5.5.46
  - PHP  5.4.45
  - PHPMyAdmin 4.2.3
2. **senki/trusty**
  - Ubuntu Trusty x64 (14.04 LTS)
  - Apache 2.4.7
  - MySQL 5.6.27
  - PHP 5.5.9
  - PHPMyAdmin 4.2.3

## Usage

Use the included `run.sh` script:

```
Usage: ./run.sh [subcommand] [target]

Available subcommands:
    test           Recereate and running test boxes
    build          Build vagrant boxes
    add            Removing previous, rebuilding & adding new boxes
                   This deletes '.box' file after publish

Available targets:
    all            Select all boxes
    precise        Select 'precise' x64 box
    trusty         Select 'trusty' x64 box
```

After `./run.sh test all`, you have a `precise_test`, `trusty_test` machine up & running.  
After `./run.sh build all`, you have a `precise.box`,`trusty.box` box files in `dist` directory.  
After `./run.sh add all`, you have a `senki/precise`,`senki/trusty` boxes added to your vagrant environment. Check with `vagrant box list`

## Pre-requirements on OS X

  - [homebrew](http://brew.sh)
  - [git](http://www.git-scm.com) (recommended via homebrew: `brew install git`)
  - [VirtualBox](https://www.virtualbox.org)
  - [Vagrant](https://www.vagrantup.com)
  - [vagrant-reload](https://github.com/aidanns/vagrant-reload)

## Install

```sh
$ git clone --depth=1 https://github.com/senki/vagrant-boxes.git
```
## Copyright and license

Code and documentation Copyright 2015 Csaba Maulis. Released under [the MIT license](LICENSE).
