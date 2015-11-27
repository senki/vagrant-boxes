#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# The MIT License (MIT)

# To re-run full provisioning, delete /var/provision/* files and run
#  $ vagrant provision trusty --provision-with shell
# From the host machine

HOST_NAME="lamp-trusty.local"
WWW_ROOT="/var/www/html"

do_install_php() {
    if [ -f "/var/provision/install-php" ]; then
        echo -e "Skipping: PHP Extensions already installed\n"  | tee -a $PROVISION_LOG
        return
    fi
    echo -e "Installing PHP Extensions...\n"  | tee -a $PROVISION_LOG
    apt-get -y install php5-curl php5-mcrypt libmcrypt-dev mcrypt >> $PROVISION_LOG 2>&1
    php5enmod mcrypt
    service apache2 restart >> $PROVISION_LOG 2>&1
    touch /var/provision/install-php
    echo -e "\n" >> $PROVISION_LOG 2>&1
}

source common/*.sh

# Script start here
main
