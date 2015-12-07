#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# SEE LICENSE File

# To re-run full provisioning, delete /var/provision/* files and run
#  $ vagrant provision trusty
# From the host machine

set -e

BASE_OS="trusty64"
HOST_NAME="lamp-trusty.local"
WWW_ROOT="/var/www/html"
WWW_CONF_PATTERN="\tDocumentRoot \/var\/www\/html"
WWW_DEFAULT_CONF="000-default.conf"

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

source /vagrant/src/common.sh

# Script start here
main
