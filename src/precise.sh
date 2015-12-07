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
WWW_CONF_PATTERN="\t<Directory \/var\/www\/>"
WWW_DEFAULT_CONF="default"

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

source /vagrant/src/common.sh

# Script start here
main
