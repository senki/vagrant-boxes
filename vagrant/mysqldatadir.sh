#!/bin/sh

### BEGIN INIT INFO
# Provides:          mysqldatadir.sh
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# X-Start-Before:    mysql
# X-Stop-After:      mysql
# Short-Description: Backup and restore MySQL data directory.
# Description:       Use in your Vagrant box.
### END INIT INFO

# Copyright (c) 2015 Csaba Maulis
#
# The MIT License (MIT)

case "$1" in
    start)
        echo "Restoring MySQL Data directory. Or first time backup."
        if [ ! -f "/vagrant/vagrant/db/mysql.tar.gz" ]; then
            tar -czf /vagrant/vagrant/db/mysql.tar.gz -C /var/lib/mysql/ . # backup
        else
            service mysql stop
            rm -rf /var/lib/mysql/*
            tar -xzf /vagrant/vagrant/db/mysql.tar.gz -C /var/lib/mysql/ # restore
            service mysql start
        fi
        ;;
    stop)
        echo "Backup MySQL Data directory"
        tar -czf /vagrant/vagrant/db/mysql.tar.gz -C /var/lib/mysql/ . # backup
        ;;
    *)
        echo "Usage: mysqldatadir.sh start|stop"
        echo "       start means 'restore'"
        echo "       stop  means 'backup'"
        exit 1
        ;;
esac

exit 0
