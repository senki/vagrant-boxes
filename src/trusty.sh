#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# SEE LICENSE File

# To re-run full provisioning, delete /var/provision/* files and run
#  $ vagrant provision trusty
# From the host machine

set -e

BASE_OS="trusty"
HOST_NAME="lamp-trusty.local"
WWW_ROOT="/var/www/html"

do_install_php() {
    if [ -f "/var/provision/install-php" ]; then
        echo "Skipping: PHP Extensions already installed"  | tee -a $PROVISION_LOG
        return
    fi
    echo "Installing PHP Extensions..."  | tee -a $PROVISION_LOG
    apt-get -qy install php5 php5-curl php5-mcrypt libmcrypt-dev mcrypt >> $PROVISION_LOG 2>&1
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
    sed -i "s/AllowOverride None/AllowOverride All/" /etc/apache2/apache2.conf
    # virtualbox shared folder
    sed -i "s/^\tDocumentRoot \/var\/www\/html$/&\n\tEnableSendfile Off/" /etc/apache2/sites-available/000-default.conf
    service apache2 restart >> $PROVISION_LOG 2>&1
    touch /var/provision/apache
}

source /vagrant/src/common.sh

# Script start here
main
