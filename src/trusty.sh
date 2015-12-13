#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# SEE LICENSE File

# To re-run full provisioning, delete /var/provision/* files and run
#  $ vagrant provision trusty
# From the host machine

set -e

BASE_OS="trusty"
HOST_NAME="senki-trusty.local"
WWW_ROOT="/var/www/html"

do_install_os_specific() {
    if [ -f "/var/provision/install-${BASE_OS}-specific" ]; then
        echo "Skipping: ${BASE_OS} specific packages already installed"  | tee -a $PROVISION_LOG
        return
    fi
    echo "Installing ${BASE_OS} specific packages..."  | tee -a $PROVISION_LOG
    apt-get -qy install php5 php5-curl php5-mcrypt libmcrypt-dev mcrypt >> $PROVISION_LOG 2>&1
    php5enmod mcrypt >> $PROVISION_LOG 2>&1
    touch /var/provision/install-${BASE_OS}-specific
}

do_config_os_specific() {
    if [ -f "/var/provision/config-${BASE_OS}-specific" ]; then
        echo "Skipping: ${BASE_OS} specific config already in place"  | tee -a $PROVISION_LOG
        return
    fi
    echo "Configuring ${BASE_OS} specific things..."  | tee -a $PROVISION_LOG
    # .htaccess
    sed -i "s/AllowOverride None/AllowOverride All/" /etc/apache2/apache2.conf
    # virtualbox shared folder
    sed -i "s/^\tDocumentRoot \/var\/www\/html$/&\n\tEnableSendfile Off/" /etc/apache2/sites-available/000-default.conf
    service apache2 restart >> $PROVISION_LOG 2>&1
    touch /var/provision/config-${BASE_OS}-specific
}

source /vagrant/src/common.sh

# Script start here
main
