# vagrant-boxes

Create Basic Ubuntu LAMP Vagrant boxes.  
Only with VirtualBox provider.

>WIP – currently `senki/[boxname]` not available for downloads.

## Features

- Install/update VirtualBox Additions
- Automatically backup `/var/lib/mysql/` dir on guest shutdown event to `vagrant/db/mysql-{$NOW}.tar.gz`
- Manually backup or restore `/var/lib/mysql/` dir with  `/etc/init.d/mysqlbackuphandler.sh`
- Provision 'check' files: `/var/provision/*`, to safely re-provison boxes.
- Provision logs:
  - guest: `/var/log/provision.log`
  - host: `vagrant/log/{$HOST_NAME}-{$NOW}.log`
- Box version string saved in guest's `/var/provision/version` file
- Installed utilities: ruby, htop, tree, multitail

## Boxes

1. **senki/trusty**
  - Ubuntu Trusty x64 (14.04.5 LTS)
  - Apache 2.4.7
  - MySQL 5.6.33
  - PHP 5.5.9
  - Adminer 4.2.5
2. **senki/xenial**
  - Ubuntu Trusty x64 (14.04.1 LTS)
  - Apache 2.4.18
  - MySQL 5.7.16
  - PHP 7.0.8
  - Adminer 4.2.5

### Test boxes

You can test newly created boxes via `boxmgr build [boxname]_test`. It's building and open in a browser.

## Usage

Use the included `boxmgr` script, for all arguments see built-in help.

1. boxmgr build [boxname]
2. boxmgr update-vbox [boxname] # if you need to upgrade VBoxGuestAdditions manually
3. boxmgr add [boxname]

On end, you have a `senki/[box]` added to your Vagrant environment. Check with `vagrant box list`.

## Pre-requirements on OS X

  - [git](http://www.git-scm.com) (recommended via homebrew: `brew install git`)
  - [VirtualBox](https://www.virtualbox.org)
  - [Vagrant](https://www.vagrantup.com)
  - [vagrant-reload](https://github.com/aidanns/vagrant-reload)
  - [vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest)

## Install

```sh
$ git clone --depth=1 https://github.com/senki/vagrant-boxes.git
```
## Copyright and license

Code and documentation Copyright 2015 Csaba Maulis. Released under [the MIT license](LICENSE).
