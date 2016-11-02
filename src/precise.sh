#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# SEE LICENSE File

# To re-run full provisioning, delete /var/provision/* files and run
#  $ vagrant provision precise
# From the host machine

set -e

BASE_OS="precise"
# shellcheck disable=SC2034
RUBY_EXEC="ruby1.9.1"

do_os_prepare() {
    if [[ -f "/var/provision/${BASE_OS}-prepare" ]]; then
        echo -e "Skipping: $BASE_OS Specific Environment already prepared" | tee -a $PROVISION_LOG
        return
    fi
    echo -e "Preparing $BASE_OS Specific Environment..." | tee -a $PROVISION_LOG
    # empty
    touch /var/provision/${BASE_OS}-prepare
}

do_install_os_specific() {
    if [[ -f "/var/provision/${BASE_OS}-install" ]]; then
        echo "Skipping: $BASE_OS specific packages already installed"  | tee -a "$PROVISION_LOG"
        return
    fi
    echo "Installing $BASE_OS specific packages..." | tee -a "$PROVISION_LOG"
    {
        apt-get -qy install python-software-properties "$RUBY_EXEC"
        add-apt-repository -y ppa:ondrej/php5-oldstable
        apt-get -qy update
        apt-get -qy install php5 php5-curl php5-intl php5-mysqlnd php5-readline php5-xsl php5-mcrypt libmcrypt-dev mcrypt
        php5enmod curl intl mysqlnd readline xsl mcrypt
    } >> "$PROVISION_LOG" 2>&1
    touch /var/provision/${BASE_OS}-install
}

do_config_os_specific() {
    if [[ -f "/var/provision/${BASE_OS}-config" ]]; then
        echo "Skipping: $BASE_OS specific config already in place"  | tee -a "$PROVISION_LOG"
        return
    fi
    echo "Configuring $BASE_OS specific things..."  | tee -a "$PROVISION_LOG"
    # php.ini
    {
        mv /etc/php5/apache2/php.ini /etc/php5/apache2/php.ini.bak
        cp -s /usr/share/php5/php.ini-development /etc/php5/apache2/php.ini
    } >> "$PROVISION_LOG" 2>&1
    # .htaccess
    sed -i "s/AllowOverride None/AllowOverride All/" /etc/apache2/sites-available/default
    # virtualbox shared folder
    sed -i "s/^\t<Directory \/var\/www\/>$/&\n\t\tEnableSendfile Off/" /etc/apache2/sites-available/default
    service apache2 restart >> "$PROVISION_LOG" 2>&1
    touch /var/provision/${BASE_OS}-config
}

# shellcheck disable=SC1091
source /vagrant/src/common.sh

# Script start here
main
