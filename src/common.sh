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
VBOX_GA_VERS="5.0.12"

MYSQL_ROOT_PASS="vagrant"
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
    echo "Europe/Budapest" > /etc/timezone
    dpkg-reconfigure -f noninteractive tzdata >> $PROVISION_LOG 2>&1
    # set locales
    export LANGUAGE="en_US.UTF-8"
    export LC_ALL="en_US.UTF-8"
    echo 'LANGUAGE="en_US.UTF-8"' >> $LOCALE_CONFIG
    echo 'LC_ALL="en_US.UTF-8"' >> $LOCALE_CONFIG
    # ssh loce not accept from client
    sed -i "s/^AcceptEnv LANG LC_\*$/\# AcceptEnv LANG LC_\*/g" /etc/ssh/sshd_config
    touch /var/provision/prepare
}

do_install_vbox_ga() {
    if [[ -f "/var/provision/install-vbox_ga_$VBOX_GA_VERS" ]]; then
        echo "Skipping: VirtualBox Guest Additions v$VBOX_GA_VERS already installed" | tee -a $PROVISION_LOG
        return
    fi
    echo "Installing VirtualBox Guest Additions v$VBOX_GA_VERS..." | tee -a $PROVISION_LOG
    apt-get -qy remove virtualbox-\* >> $PROVISION_LOG 2>&1
    apt-get -qy purge virtualbox-\* >> $PROVISION_LOG 2>&1
    apt-get -qy install build-essential linux-headers-generic dkms >> $PROVISION_LOG 2>&1
    if [[ ! -f "/vagrant/src/vbox_ga_$VBOX_GA_VERS.iso" ]]; then
        curl -s -L -o /vagrant/src/vbox_ga_$VBOX_GA_VERS.iso http://download.virtualbox.org/virtualbox/$VBOX_GA_VERS/VBoxGuestAdditions_$VBOX_GA_VERS.iso >> $PROVISION_LOG 2>&1
    fi
    mkdir /media/vbox_ga_$VBOX_GA_VERS
    mount -o loop /vagrant/src/vbox_ga_$VBOX_GA_VERS.iso /media/vbox_ga_$VBOX_GA_VERS >> $PROVISION_LOG 2>&1
    export REMOVE_INSTALLATION_DIR=0
    sh /media/vbox_ga_$VBOX_GA_VERS/VBoxLinuxAdditions.run --nox11 >> $PROVISION_LOG 2>&1
    umount /media/vbox_ga_$VBOX_GA_VERS >> $PROVISION_LOG 2>&1
    rmdir /media/vbox_ga_$VBOX_GA_VERS
    touch /var/provision/install-vbox_ga_$VBOX_GA_VERS
}

do_update() {
    if [[ -f "/var/provision/update" ]] && [[ `stat --format=%Y /var/provision/update` -ge $(( `date +%s` - (60*60*24) )) ]]; then
        echo "Skipping: System already updated within a day" | tee -a $PROVISION_LOG
        return
    fi
    echo "Updating System..."  | tee -a $PROVISION_LOG
    apt-get -qy update >> $PROVISION_LOG 2>&1
    apt-get -qy dist-upgrade >> $PROVISION_LOG 2>&1
    apt-get -qy autoremove >> $PROVISION_LOG 2>&1
    touch /var/provision/update
}

do_config_network() {
    if [[ -f "/var/provision/config-network" ]]; then
        echo "Skipping: Hostname already confugured" | tee -a $PROVISION_LOG
        return
    fi
    echo "Configuring Hostname..."  | tee -a $PROVISION_LOG
    IPADDR=$(/sbin/ifconfig eth1 | awk '/inet / { print $2 }' | sed 's/addr://')
    sed -i "s/^${IPADDR}.*//" $HOST_CONFIG
    echo ${IPADDR} ${HOST_NAME} >> $HOST_CONFIG           # Just to quiet down some error messages
    touch /var/provision/config-network
}

do_install_lamp() {
    if [[ -f "/var/provision/install-lamp" ]]; then
        echo "Skipping: LAMP Stack already installed" | tee -a $PROVISION_LOG
        return
    fi
    export DEBIAN_FRONTEND=noninteractive
    echo "Installing LAMP Stack..."  | tee -a $PROVISION_LOG
    debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASS"
    debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASS"
    apt-get -qy install lamp-server^ >> $PROVISION_LOG 2>&1
    a2enmod rewrite >> $PROVISION_LOG 2>&1
    service apache2 restart >> $PROVISION_LOG 2>&1
    sed -i "s/^\#general_log/general_log/g" /etc/mysql/my.cnf
    touch /var/provision/install-lamp
}

do_config_mysqlbackuphandler() {
    if [[ -f "/var/provision/config-mysqlbackuphandler" ]]; then
        echo "Skipping: MySQL Data backup/restore handler already configured..." | tee -a $PROVISION_LOG
        return
    fi
    echo "Setting up MySQL Data backup/restore handler..." | tee -a $PROVISION_LOG
    cp /vagrant/src/mysqlbackuphandler.sh /etc/init.d/mysqlbackuphandler.sh
    chmod +x /etc/init.d/mysqlbackuphandler.sh
    update-rc.d mysqlbackuphandler.sh defaults  >> $PROVISION_LOG 2>&1
    /etc/init.d/mysqlbackuphandler.sh backup >> $PROVISION_LOG 2>&1
    touch /var/provision/config-mysqlbackuphandler
}

do_install_utilities() {
    if [[ -f "/var/provision/install-utilities" ]]; then
        echo "Skipping: Utility softwares already installed" | tee -a $PROVISION_LOG
        return
    fi
    echo "Installing utility softwares..." | tee -a $PROVISION_LOG
    # htop, ruby, tree, wget
    apt-get -qy install htop ruby1.9.1 tree wget >> $PROVISION_LOG 2>&1
    # multitail
    apt-get -qy install libncursesw5-dev >> $PROVISION_LOG 2>&1
    curl -s -L -O https://github.com/flok99/multitail/archive/v6.3.tar.gz >> $PROVISION_LOG 2>&1
    tar xzf v6.3.tar.gz
    rm v6.3.tar.gz
    cd multitail-6.3 && make install -s >> $PROVISION_LOG 2>&1 && cd ..
    rm -rf multitail-6.3
    cp /etc/multitail.conf.new $MULTITAIL_CONFIG
    sed -i "s/^xclip:\/usr\/bin\/xclip$/\# xclip:\/usr\/bin\/xclip/g" $MULTITAIL_CONFIG
    updatedb >> $PROVISION_LOG 2>&1
    touch /var/provision/install-utilities
}

do_save_version() {
    if [[ -f "/var/provision/version" ]]; then
        echo "Version info from already stored:" | tee -a $PROVISION_LOG
        echo "/var/provision/version: \"$(cat /var/provision/version)\"" | tee -a $PROVISION_LOG
        return
    fi
    echo "Saving version info to file..." | tee -a $PROVISION_LOG
    BOX_NAME=$(cat /vagrant/src/${BASE_OS}.json | ruby1.9.1 -rjson -e 'j = JSON.parse(STDIN.read); puts j["name"]')
    BOX_VERSION=$(cat /vagrant/src/${BASE_OS}.json | ruby1.9.1 -rjson -e 'j = JSON.parse(STDIN.read); puts j["versions"][0]["version"]')
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
    do_install_vbox_ga
    echo -n "==> " >> $PROVISION_LOG 2>&1
    do_update
    if [[ $TARGET == "test" ]]; then
        echo -n "==> " >> $PROVISION_LOG 2>&1
        do_config_network
    fi
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
    echo -n "==>" >> $PROVISION_LOG 2>&1
    echo -n "Cleanup" | tee -a $PROVISION_LOG
    apt-get -qy autoremove >> $PROVISION_LOG 2>&1
    apt-get -qy autoclean >> $PROVISION_LOG 2>&1
    echo -n "==> " >> $PROVISION_LOG 2>&1
    do_save_version
    echo "All done"
    echo "==> Box provisioning done at: $(date)" >> $PROVISION_LOG 2>&1
    NOW=$(date +"%Y-%m-%d-%H-%M-%S")
    cp $PROVISION_LOG /vagrant/vagrant/log/${BASE_OS}-$TARGET-$NOW.log
}
