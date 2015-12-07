#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# SEE LICENSE File

# To re-run full provisioning, delete /var/provision/* files and run
#  $ vagrant provision precise
# From the host machine

set -e

BASE_OS="precise64"
HOST_NAME="lamp-precise.local"
WWW_ROOT="/var/www"

do_install_php() {
    if [ -f "/var/provision/install-php" ]; then
        echo "Skipping: PHP v5.4 already installed"  | tee -a $PROVISION_LOG
        return
    fi
    echo "Installing PHP v5.4..."  | tee -a $PROVISION_LOG
    add-apt-repository -y ppa:ondrej/php5-oldstable >> $PROVISION_LOG 2>&1
    apt-get -qy update >> $PROVISION_LOG 2>&1
    apt-get -qy install php5 php5-curl php5-mcrypt libmcrypt-dev mcrypt >> $PROVISION_LOG 2>&1
    apt-get -qy dist-upgrade >> $PROVISION_LOG 2>&1
    php5enmod mcrypt >> $PROVISION_LOG 2>&1
    touch /var/provision/install-php
}

do_config_apache() {
    if [ -f "/var/provision/apache" ]; then
        echo "Skipping: Apache environment already cinfigured"  | tee -a $PROVISION_LOG
        return
    fi
    echo "Configuring apache environment..."  | tee -a $PROVISION_LOG
    # .htaccess
    sed -i "s/AllowOverride None/AllowOverride All/" /etc/apache2/sites-available/default
    # virtualbox shared folder
    sed -i "s/^\t<Directory \/var\/www\/>$/&\n\t\tEnableSendfile Off/" /etc/apache2/sites-available/default
    service apache2 restart >> $PROVISION_LOG 2>&1
    touch /var/provision/apache
}

source /vagrant/src/common.sh

# Script start here
main
