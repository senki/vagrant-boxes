#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# SEE LICENSE File

# To re-run full provisioning, delete /var/provision/* files and run
#  $ vagrant provision
# From the host machine

HOST_CONFIG="/etc/hosts"
LOCALE_CONFIG="/etc/default/locale"
MULTITAIL_CONFIG="/etc/multitail.conf"
SSHD_CONFIG="/etc/ssh/sshd_config"
TIMEZONE_CONFIG="/etc/timezone"

MYSQL_ROOT_PASS="vagrant"
PHPMYADMIN_APP_PASS="vagrant"
PROVISION_LOG="/var/log/provision.log"

do_prepare() {
    if [ -f "/var/provision/prepare" ]; then
        echo -e "Skipping: Environment already prepared\n" | tee -a $PROVISION_LOG
        return
    fi
    echo -e "Preparing environment...\n" | tee -a $PROVISION_LOG
    # remove tty warning
    sed -i "s/^mesg n$/tty -s \&\& mesg n/g" /root/.profile
    # set timezone
    echo "Europe/Budapest" > $TIMEZONE_CONFIG
    dpkg-reconfigure -f noninteractive tzdata >> $PROVISION_LOG 2>&1
    # set locales
    export LANGUAGE="en_US.UTF-8"
    export LC_ALL="en_US.UTF-8"
    echo 'LANGUAGE="en_US.UTF-8"' >> $LOCALE_CONFIG
    echo 'LC_ALL="en_US.UTF-8"' >> $LOCALE_CONFIG
    # ssh loce not accept from client
    sed -i "s/^AcceptEnv LANG LC_\*$/\# AcceptEnv LANG LC_\*/g" $SSHD_CONFIG
    touch /var/provision/prepare
    echo -e "\n" >> $PROVISION_LOG 2>&1
}

do_update() {
    if [ -f "/var/provision/update" ] && [ `stat --format=%Y /var/provision/update` -ge $(( `date +%s` - (60*60*24) )) ]; then
        echo -e "Skipping: System already updated within a day\n" | tee -a $PROVISION_LOG
        return
    fi
    echo -e "Updating System...\n"  | tee -a $PROVISION_LOG
    apt-get update >> $PROVISION_LOG 2>&1
    apt-get -y dist-upgrade >> $PROVISION_LOG 2>&1
    apt-get -y autoremove >> $PROVISION_LOG 2>&1
    touch /var/provision/update
    echo -e "\n" >> $PROVISION_LOG 2>&1
}

do_network() {
    if [ -f "/var/provision/network" ]; then
        echo -e "Skipping: Hostname already confugured\n" | tee -a $PROVISION_LOG
        return
    fi
    echo -e "Configuring hostname...\n"  | tee -a $PROVISION_LOG
    IPADDR=$(/sbin/ifconfig eth1 | awk '/inet / { print $2 }' | sed 's/addr://')
    sed -i "s/^${IPADDR}.*//" $HOST_CONFIG
    echo ${IPADDR} ${HOST_NAME} >> $HOST_CONFIG           # Just to quiet down some error messages
    touch /var/provision/network
    echo -e "\n" >> $PROVISION_LOG 2>&1
}

do_install_lamp() {
    if [ -f "/var/provision/install-lamp" ]; then
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
    touch /var/provision/install-lamp
    echo -e "\n" >> $PROVISION_LOG 2>&1
}

do_files() {
    if [ -f "/var/provision/files" ]; then
        echo -e "Skipping: WWW files already in place...\n" | tee -a $PROVISION_LOG
        return
    fi
    echo -e "Setting up WWW files...\n" | tee -a $PROVISION_LOG
    service apache2 stop >> $PROVISION_LOG 2>&1
    rm -rf $WWW_ROOT
    ln -fs /vagrant/wwwroot $WWW_ROOT
    service apache2 start >> $PROVISION_LOG 2>&1
    touch /var/provision/files
    echo -e "\n" >> $PROVISION_LOG 2>&1
}

do_install_phpmyadmin() {
    if [ -f "/var/provision/install-phpmyadmin" ]; then
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
    touch /var/provision/install-phpmyadmin
    echo -e "\n" >> $PROVISION_LOG 2>&1
}

do_install_utilities() {
    if [ -f "/var/provision/install-utilities" ]; then
        echo -e "Skipping: Utility softwares already installed\n" | tee -a $PROVISION_LOG
        return
    fi
    echo -e "Installing utility softwares...\n" | tee -a $PROVISION_LOG
    # multitail
    apt-get -y install libncursesw5-dev >> $PROVISION_LOG 2>&1
    curl -s -L -O https://github.com/flok99/multitail/archive/v6.3.tar.gz >> $PROVISION_LOG 2>&1
    tar xzf v6.3.tar.gz
    rm v6.3.tar.gz
    cd multitail-6.3 && make install >> $PROVISION_LOG 2>&1 && cd ..
    rm -rf multitail-6.3
    cp /etc/multitail.conf.new $MULTITAIL_CONFIG
    sed -i "s/^xclip:\/usr\/bin\/xclip$/\# xclip:\/usr\/bin\/xclip/g" $MULTITAIL_CONFIG
    touch /var/provision/install-utilities
    echo -e "\n" >> $PROVISION_LOG 2>&1
}

main() {
    if [ ! -f $PROVISION_LOG ]; then
        touch $PROVISION_LOG
    fi
    echo -e "\n" >> $PROVISION_LOG 2>&1
    echo -e "$(date): Provisioning start\n" >> $PROVISION_LOG 2>&1
    if [ ! -d "/var/provision" ]; then
        mkdir /var/provision
    fi
    do_prepare
    do_update
    if [[ "$1" -eq "test" ]]; then
        do_network
    fi
    do_install_php
    do_install_lamp
    if [[ "$1" -eq "test" ]]; then
        do_files
    fi
    do_install_phpmyadmin
    do_install_utilities
    if [ -f /var/run/reboot-required ]; then
        reboot >> $PROVISION_LOG 2>&1
    fi
    echo -e "All done"
    echo -e "$(date): Provisioning done\n" >> $PROVISION_LOG 2>&1
}
