#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# SEE LICENSE File

# To re-run full provisioning, delete /var/provision/* files and run
#  $ vagrant provision precise
# From the host machine

HOST_NAME="lamp-precise.local"
WWW_ROOT="/var/www"

do_install_php() {
    if [ -f "/var/provision/install-php" ]; then
        echo -e "Skipping: PHP v5.4 already installed\n"  | tee -a $PROVISION_LOG
        return
    fi
    echo -e "Installing PHP v5.4...\n"  | tee -a $PROVISION_LOG
    add-apt-repository -y ppa:ondrej/php5-oldstable >> $PROVISION_LOG 2>&1
    apt-get update >> $PROVISION_LOG 2>&1
    apt-get -y install php5 php5-curl php5-mcrypt libmcrypt-dev mcrypt >> $PROVISION_LOG 2>&1
    apt-get -y dist-upgrade >> $PROVISION_LOG 2>&1
    php5enmod mcrypt
    touch /var/provision/install-php
    echo -e "\n" >> $PROVISION_LOG 2>&1
}

source /vagrant/src/common.sh

# Script start here
main
