#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# SEE LICENSE File

# To re-run full provisioning, delete /var/provision/* files and run
#  $ vagrant provision xenial
# From the host machine

set -e

BASE_OS="xenial"
# shellcheck disable=SC2034
RUBY_EXEC="ruby"

do_install_os_specific() {
    if [[ -f "/var/provision/${BASE_OS}-install" ]]; then
        echo "Skipping: $BASE_OS specific packages already installed"  | tee -a "$PROVISION_LOG"
        return
    fi
    echo "Installing $BASE_OS specific packages..." | tee -a "$PROVISION_LOG"

    {
        apt-get -qy install make gcc ruby php-bcmath php-bz2 php-curl php-mbstring php-zip
        phpenmod bcmath bz2 curl mbstring zip
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
        mv /etc/php/7.0/apache2/php.ini /etc/php/7.0/apache2/php.ini.bak
        cp -s /usr/lib/php/7.0/php.ini-development /etc/php/7.0/apache2/php.ini
    } >> "$PROVISION_LOG" 2>&1
    service apache2 restart >> "$PROVISION_LOG" 2>&1

    touch /var/provision/${BASE_OS}-config
}

# shellcheck disable=SC1091
source /vagrant/src/common.sh

# Script start here
main
