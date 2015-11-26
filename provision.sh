#!/usr/bin/env bash

# The MIT License (MIT)
#
# Copyright (c) 2015 Csaba Maulis
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


# To re-run full provisioning, delete /var/lock/provision-* files and run
#  $ vagrant provision
# From the host machine

HOST_NAME="lamp-base-php55.local"
# APACHE_CONFIG_FILE="/etc/apache2/envvars"
# PHP_CONFIG_FILE="/etc/php5/apache2/php.ini"
# MYSQL_CONFIG_FILE="/etc/mysql/my.cnf"
WWW_ROOT="/var/www/html"
MYSQL_ROOT_PASS="vagrant"
PHPMYADMIN_APP_PASS="vagrant"
PROVISION_LOG="/var/log/provision.log"

do_prepare() {
    if [ -f "/var/lock/provision-prepare" ]; then
        echo -e "Skipping: Environment already prepared\n" | tee -a $PROVISION_LOG
        return
    fi
    echo -e "Preparing environment...\n" | tee -a $PROVISION_LOG
    # set timezone
    echo "Europe/Budapest" > /etc/timezone
    dpkg-reconfigure -f noninteractive tzdata >> $PROVISION_LOG 2>&1
    # set locales
    export LANGUAGE="en_US.UTF-8"
    export LC_ALL="en_US.UTF-8"
    echo 'LANGUAGE="en_US.UTF-8"' >> /etc/default/locale
    echo 'LC_ALL="en_US.UTF-8"' >> /etc/default/locale
    # ssh loce not accept from client
    sed -i "s/^AcceptEnv LANG LC_\*$/\# AcceptEnv LANG LC_\*/g" /etc/ssh/sshd_config
    touch /var/lock/provision-prepare
    echo -e "\n" >> $PROVISION_LOG 2>&1
}

do_update() {
    if [ -f "/var/lock/provision-update" ] && [ `stat --format=%Y /var/lock/provision-update` -ge $(( `date +%s` - (60*60*24) )) ]; then
        echo -e "Skipping: System already updated within a day\n" | tee -a $PROVISION_LOG
        return
    fi
    echo -e "Updating System...\n"  | tee -a $PROVISION_LOG
    apt-get update >> $PROVISION_LOG 2>&1
    apt-get -y dist-upgrade >> $PROVISION_LOG 2>&1
    touch /var/lock/provision-update
    echo -e "\n" >> $PROVISION_LOG 2>&1
}

do_network() {
    if [ -f "/var/lock/provision-network" ]; then
        echo -e "Skipping: Hostname already confugured\n" | tee -a $PROVISION_LOG
        return
    fi
    echo -e "Configuring hostname...\n"  | tee -a $PROVISION_LOG
    IPADDR=$(/sbin/ifconfig eth1 | awk '/inet / { print $2 }' | sed 's/addr://')
    sed -i "s/^${IPADDR}.*//" /etc/hosts
    echo ${IPADDR} ${HOST_NAME} >> /etc/hosts           # Just to quiet down some error messages
    touch /var/lock/provision-network
    echo -e "\n" >> $PROVISION_LOG 2>&1
}

do_install_lamp() {
    if [ -f "/var/lock/provision-install-lamp" ]; then
        echo -e "Skipping: LAMP Stack already installed\n" | tee -a $PROVISION_LOG
        return
    fi
    export DEBIAN_FRONTEND=noninteractive
    echo -e "Installing & Configuring LAMP Stack...\n"  | tee -a $PROVISION_LOG
    debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASS"
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASS"
    tasksel install lamp-server
    a2enmod rewrite >> $PROVISION_LOG 2>&1
    service apache2 restart >> $PROVISION_LOG 2>&1
    touch /var/lock/provision-install-lamp
    echo -e "\n" >> $PROVISION_LOG 2>&1
}

do_install_php() {
    if [ -f "/var/lock/provision-install-php" ]; then
        echo -e "Skipping: PHP Extensions already installed\n"  | tee -a $PROVISION_LOG
        return
    fi
    echo -e "Installing PHP Extensions...\n"  | tee -a $PROVISION_LOG
    apt-get -y install php5-curl php5-mcrypt libmcrypt-dev mcrypt >> $PROVISION_LOG 2>&1
    php5enmod mcrypt
    service apache2 restart >> $PROVISION_LOG 2>&1
    touch /var/lock/provision-install-php
    echo -e "\n" >> $PROVISION_LOG 2>&1
}

do_files() {
    if [ -f "/var/lock/provision-files" ]; then
        echo -e "Skipping: WWW files already in place...\n" | tee -a $PROVISION_LOG
        return
    fi
    echo -e "Setting up WWW files...\n" | tee -a $PROVISION_LOG
    service apache2 stop >> $PROVISION_LOG 2>&1
    rm -rf $WWW_ROOT
    ln -fs /vagrant/src $WWW_ROOT
    service apache2 start >> $PROVISION_LOG 2>&1
    touch /var/lock/provision-files
    echo -e "\n" >> $PROVISION_LOG 2>&1
}

do_install_phpmyadmin() {
    if [ -f "/var/lock/provision-install-phpmyadmin" ]; then
        echo -e "Skipping: phpMyAdmin already installed\n" | tee -a $PROVISION_LOG
        return
    fi

    echo -e "Installing phpMyAdmin...\n" | tee -a $PROVISION_LOG
    add-apt-repository -y ppa:nijel/phpmyadmin >> $PROVISION_LOG 2>&1
    apt-get update >> $PROVISION_LOG 2>&1
    debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-user string root"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $MYSQL_ROOT_PASS"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_PASS"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PHPMYADMIN_APP_PASS"
    apt-get -y install phpmyadmin >> $PROVISION_LOG 2>&1
    touch /var/lock/provision-install-phpmyadmin
    echo -e "\n" >> $PROVISION_LOG 2>&1
}

do_install_utilities() {
    if [ -f "/var/lock/provision-install-utilities" ]; then
        echo -e "Skipping: Utility softwares already installed\n" | tee -a $PROVISION_LOG
        return
    fi
    echo -e "Installing utility softwares...\n" | tee -a $PROVISION_LOG
    # multitail
    apt-get -y install libncursesw5-dev >> $PROVISION_LOG 2>&1
    curl -s -L -O https://github.com/flok99/multitail/archive/v6.3.tar.gz >> $PROVISION_LOG 2>&1
    tar xzf v6.3.tar.gz
    rm v6.3.tar.gz
    cd multitail-6.3 && make install  >> $PROVISION_LOG 2>&1 && cd ..
    rm -rf multitail-6.3
    cp /etc/multitail.conf.new /etc/multitail.conf
    sed -i "s/^xclip:\/usr\/bin\/xclip$/\# xclip:\/usr\/bin\/xclip/g" /etc/multitail.conf
    touch /var/lock/provision-install-utilities
    echo -e "\n" >> $PROVISION_LOG 2>&1
}

# Start here
#
if [ ! -f $PROVISION_LOG ]; then
    touch $PROVISION_LOG
fi
echo -e "\n" >> $PROVISION_LOG 2>&1
echo -e "$(date): Provisioning start\n" >> $PROVISION_LOG 2>&1
do_prepare
do_update
do_network
do_install_lamp
do_install_php
do_files
do_install_phpmyadmin
do_install_utilities

echo -e "All done"
echo -e "$(date): Provisioning done\n" >> $PROVISION_LOG 2>&1
