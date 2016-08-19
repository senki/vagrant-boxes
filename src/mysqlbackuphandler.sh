#!/bin/bash

### BEGIN INIT INFO
# Provides:          mysqlbackuphandler.sh
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Backup and restore MySQL data directory.
# Description:       Use in your Vagrant box.
### END INIT INFO

# Copyright (c) 2015 Csaba Maulis
#
# The MIT License (MIT)

do_help() {
    echo "Argument missing or invalid!"
    echo ""
    echo "Usage: $0 start|stop|backup|restore <filename>"
    echo ""
    echo "       start & stop           does exactly as 'backup'"
    echo "       backup                 backups mysql dir to the '/vagrant/vagrant/db' directory"
    echo "       restore                needs additional parameter: <filename> of db,"
    echo "                              which relative to '/vagrant/vagrant/db/' directory"
    echo ""
    echo "       (Every backup create a new file with timestamps on in name. Old backups never deleted.)"
    echo ""
}

NOW=$(date +"%Y-%m-%d-%H-%M-%S")

case "$1" in
    start|stop|backup)
        echo "Backup MySQL Data directory"
        tar -czf /vagrant/vagrant/db/mysql-${NOW}.tar.gz -C /var/lib/mysql/ . # backup
        ;;
    restore)
        if [[ $2 -eq 0 ]]; then
            do_help
            exit 1
        elif [[ -f "/vagrant/vagrant/db/${2}" ]]; then
        echo "Restoring MySQL Data directory"
            service mysql stop
            rm -rf /var/lib/mysql/*
            tar -xzf /vagrant/vagrant/db/${2} -C /var/lib/mysql/ # restore
            service mysql start
        else
            do_help
            exit 1
        fi
        ;;
    *)
        do_help
        exit 1
        ;;
esac

exit 0
