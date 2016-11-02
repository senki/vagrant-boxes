#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# SEE LICENSE File

# To re-run full provisioning, delete /var/provision/* files and run
#  $ vagrant provision trusty
# From the host machine

set -e

BASE_OS="trusty"
# shellcheck disable=SC2034
RUBY_EXEC="ruby"

do_install_os_specific() {
    if [[ -f "/var/provision/${BASE_OS}-install" ]]; then
        echo "Skipping: $BASE_OS specific packages already installed"  | tee -a "$PROVISION_LOG"
        return
    fi
    echo "Installing $BASE_OS specific packages..." | tee -a "$PROVISION_LOG"
    debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_PASS"
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_PASS"
    {
        apt-get -qy install mysql-server-5.6 php5 php5-curl php5-intl php5-mysqlnd php5-readline php5-xsl php5-mcrypt libmcrypt-dev mcrypt
        php5enmod curl intl mysqlnd readline xsl mcrypt
    } >> "$PROVISION_LOG" 2>&1
    touch /var/provision/${BASE_OS}-install
}

do_config_os_specific() {
    if [[ -f "/var/provision/${BASE_OS}-config" ]]; then
        echo "Skipping: $BASE_OS specific config already in place"  | tee -a "$PROVISION_LOG"
        return
    fi
    echo "Setting $BASE_OS specific configs..."  | tee -a "$PROVISION_LOG"
    # php.ini
    {
        mv /etc/php5/apache2/php.ini /etc/php5/apache2/php.ini.bak
        cp -s /usr/share/php5/php.ini-development /etc/php5/apache2/php.ini
    } >> "$PROVISION_LOG" 2>&1
    # .htaccess
    sed -i "s/AllowOverride None/AllowOverride All/" /etc/apache2/apache2.conf
    # index.html
    if [ -f /var/www/html/index.html ]; then
        rm /var/www/html/index.html >> "$PROVISION_LOG" 2>&1
    fi
    # virtualbox shared folder
    sed -i "s/^\tDocumentRoot \/var\/www\/html$/&\n\tEnableSendfile Off/" /etc/apache2/sites-available/000-default.conf
    service apache2 restart >> "$PROVISION_LOG" 2>&1
    touch /var/provision/${BASE_OS}-config
}

# shellcheck disable=SC1091
source /vagrant/src/common.sh

# Script start here
main
