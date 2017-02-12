#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# SEE LICENSE File

# To re-run full provisioning, delete /var/provision/* files and run
#  $ vagrant provision
# From the host machine

LOCALE_CONFIG="/etc/default/locale"
MULTITAIL_CONFIG="/etc/multitail.conf"
MYSQL_PASS="vagrant"
PROVISION_LOG="/var/log/provision.log"

if [[ $# -ne 0 ]]; then
    case $1 in
        test|prod)
            TARGET=$1
            ;;
        *)
            echo "Argument missing or invalid! Exiting"
            exit 1
            ;;
    esac
else
    echo "Argument missing or invalid! Exiting"
    exit 1
fi

do_prepare() {
    if [[ -f "/var/provision/prepare" ]]; then
        echo -e "Skipping: Environment already prepared" | tee -a $PROVISION_LOG
        return
    fi
    echo -e "Preparing Environment..." | tee -a $PROVISION_LOG
    # remove tty warning
    sed -i "s/^mesg n$/tty -s \&\& mesg n/g" /root/.profile
    # set timezone
    echo "Australia/Perth" > /etc/timezone
    ln -fs /usr/share/zoneinfo/Australia/Perth /etc/localtime
    dpkg-reconfigure -f noninteractive tzdata >> $PROVISION_LOG 2>&1
    # set locales
    export LANGUAGE="en_US.UTF-8"
    export LC_ALL="en_US.UTF-8"
    echo 'LANGUAGE="en_US.UTF-8"' >> $LOCALE_CONFIG
    echo 'LC_ALL="en_US.UTF-8"' >> $LOCALE_CONFIG
    # ssh loce not accept from client
    sed -i "s/^AcceptEnv LANG LC_\*$/\# AcceptEnv LANG LC_\*/g" /etc/ssh/sshd_config
    # keep apt packages
    echo 'APT::Keep-Downloaded-Packages "true";' \
    > /etc/apt/apt.conf.d/01keep-debs
    # update apt sources
    apt-get -qy update >> $PROVISION_LOG 2>&1
    touch /var/provision/update
    touch /var/provision/prepare
}

do_install_lamp() {
    if [[ -f "/var/provision/install-lamp" ]]; then
        echo "Skipping: LAMP Stack already installed" | tee -a $PROVISION_LOG
        return
    fi
    export DEBIAN_FRONTEND=noninteractive
    echo "Installing LAMP Stack..."  | tee -a $PROVISION_LOG
    debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_PASS"
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_PASS"
    {
        apt-get -qy install lamp-server^
        a2enmod rewrite
        service apache2 restart
    }  >> $PROVISION_LOG 2>&1
    sed -i "s/^\#general_log/general_log/g" /etc/mysql/my.cnf
    touch /var/provision/install-lamp
}

do_config_mysqlbackuphandler() {
    if [[ -f "/var/provision/mysqlbackuphandler-config" ]]; then
        echo "Skipping: MySQL Data backup/restore handler already configured" | tee -a $PROVISION_LOG
        return
    fi
    echo "Setting up MySQL Data backup/restore handler..." | tee -a $PROVISION_LOG
    cp /vagrant/src/mysqlbackuphandler.sh /etc/init.d/mysqlbackuphandler.sh
    chmod +x /etc/init.d/mysqlbackuphandler.sh
    {
        update-rc.d mysqlbackuphandler.sh defaults
        /etc/init.d/mysqlbackuphandler.sh backup
    } >> $PROVISION_LOG 2>&1
    touch /var/provision/mysqlbackuphandler-config
}

do_install_utilities() {
    if [[ -f "/var/provision/install-utilities" ]]; then
        echo "Skipping: Utility softwares already installed" | tee -a $PROVISION_LOG
        return
    fi
    echo "Installing utility softwares..." | tee -a $PROVISION_LOG
    # htop, tree
    apt-get -qy install htop tree >> $PROVISION_LOG 2>&1
    # multitail
    {
        apt-get -qy install libncursesw5-dev
        curl -s -L -O https://www.vanheusden.com/multitail/multitail-6.4.2.tgz
    } >> $PROVISION_LOG 2>&1
    tar xzf multitail-6.4.2.tgz
    rm multitail-6.4.2.tgz
    cd multitail-6.4.2 && make install -s >> $PROVISION_LOG 2>&1 && cd ..
    rm -rf multitail-6.4.2
    cp /etc/multitail.conf.new $MULTITAIL_CONFIG
    sed -i "s/^xclip:\/usr\/bin\/xclip$/\# xclip:\/usr\/bin\/xclip/g" $MULTITAIL_CONFIG
    # update locate db
    updatedb >> $PROVISION_LOG 2>&1
    touch /var/provision/install-utilities
}

do_save_version() {
    if [[ -f "/var/provision/version" ]]; then
        echo "Version info already stored:" | tee -a $PROVISION_LOG
        echo "/var/provision/version: \"$(cat /var/provision/version)\"" | tee -a $PROVISION_LOG
        return
    fi
    BOX_VERSION=$(cat /vagrant/src/"$BASE_OS".json | $RUBY_EXEC -rjson -e 'j = JSON.parse(STDIN.read); puts j["versions"][0]["version"]')
    echo "Saving version info (v$BOX_VERSION) to file..." | tee -a $PROVISION_LOG
    BOX_NAME=$(cat /vagrant/src/"$BASE_OS".json | $RUBY_EXEC -rjson -e 'j = JSON.parse(STDIN.read); puts j["name"]')
    echo "$BOX_NAME v$BOX_VERSION" > /var/provision/version

}

main() {
    if [[ ! -f $PROVISION_LOG ]]; then
        touch $PROVISION_LOG
    fi
    echo "==> Box provisioning start at: $(date)" >> $PROVISION_LOG 2>&1
    if [[ ! -d "/var/provision" ]]; then
        mkdir /var/provision
    fi
    echo -n "==> " >> $PROVISION_LOG 2>&1
    do_prepare
    echo -n "==> " >> $PROVISION_LOG 2>&1
    do_install_lamp
    echo -n "==> " >> $PROVISION_LOG 2>&1
    do_install_os_specific
    echo -n "==> " >> $PROVISION_LOG 2>&1
    do_config_os_specific
    echo -n "==> " >> $PROVISION_LOG 2>&1
    do_config_mysqlbackuphandler
    echo -n "==> " >> $PROVISION_LOG 2>&1
    do_install_utilities
    echo -n "==> " >> $PROVISION_LOG 2>&1
    echo -e "Cleanup" | tee -a $PROVISION_LOG
    {
        apt-get -qy autoremove
        apt-get -qy autoclean
    } >> $PROVISION_LOG 2>&1
    echo -n "==> " >> $PROVISION_LOG 2>&1
    do_save_version
    echo "All done"
    echo "==> Box provisioning done at: $(date)" >> $PROVISION_LOG 2>&1
    NOW=$(date +"%Y-%m-%d-%H-%M-%S")
    cp $PROVISION_LOG /vagrant/vagrant/log/"$BASE_OS"-"$TARGET"-"$NOW".log
}
