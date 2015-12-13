#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# SEE LICENSE File

# To re-run full provisioning, delete /var/provision/* files and run
#  $ vagrant provision trusty
# From the host machine

set -e

BASE_OS="trusty"
if [[ $PHP_VERS -eq 7 ]]; then
    HOST_NAME="senki-trusty-php7.local"
else
    HOST_NAME="senki-trusty.local"
fi
WWW_ROOT="/var/www/html"

do_install_os_specific() {
    if [[ -f "/var/provision/install-${BASE_OS}-specific" ]]; then
        echo "Skipping: ${BASE_OS} specific packages already installed"  | tee -a $PROVISION_LOG
        return
    fi
    echo "Installing ${BASE_OS} specific packages..."  | tee -a $PROVISION_LOG
    debconf-set-selections <<< "mysql-server mysql-server/root_password password vagrant"
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password vagrant"
    if [[ $PHP_VERS -eq 7 ]]; then
        add-apt-repository -y ppa:ondrej/php-7.0 >> $PROVISION_LOG 2>&1
        apt-get -qy update >> $PROVISION_LOG 2>&1
        apt-get -qy install mysql-server-5.6 php7.0 php7.0-mysql php7.0-curl php7.0-mcrypt php7.0-intl libmcrypt-dev mcrypt >> $PROVISION_LOG 2>&1
    else
        apt-get -qy install mysql-server-5.6 php5 php5-curl php5-mcrypt php5-intl php5-xsl libmcrypt-dev mcrypt >> $PROVISION_LOG 2>&1
        php5enmod mcrypt >> $PROVISION_LOG 2>&1
        php5enmod curl >> $PROVISION_LOG 2>&1
        php5enmod xsl >> $PROVISION_LOG 2>&1
        php5enmod intl >> $PROVISION_LOG 2>&1
    fi
    touch /var/provision/install-${BASE_OS}-specific
}

do_config_os_specific() {
    if [[ -f "/var/provision/config-${BASE_OS}-specific" ]]; then
        echo "Skipping: ${BASE_OS} specific config already in place"  | tee -a $PROVISION_LOG
        return
    fi
    echo "Setting ${BASE_OS} specific configs..."  | tee -a $PROVISION_LOG
    # php.ini
    if [[ $PHP_VERS -eq 7 ]]; then
        mv /etc/php/7.0/apache2/php.ini /etc/php/7.0/apache2/php.ini.bak >> $PROVISION_LOG 2>&1
        cp -s /usr/lib/php/7.0/php.ini-development /etc/php/7.0/apache2/php.ini >> $PROVISION_LOG 2>&1
    else
        mv /etc/php5/apache2/php.ini /etc/php5/apache2/php.ini.bak >> $PROVISION_LOG 2>&1
        cp -s /usr/share/php5/php.ini-development /etc/php5/apache2/php.ini >> $PROVISION_LOG 2>&1
    fi
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
