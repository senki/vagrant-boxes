#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# SEE LICENSE File

if [[ $# -eq 1 ]]; then
  VBOX_GA_VERS=$1
else
  echo "Argument missing or invalid! Exiting"
  exit 1
fi
if [[ -f "/var/provision/install-vbox_ga_$VBOX_GA_VERS" ]]; then
    echo "Skipping: VirtualBox Guest Additions v$VBOX_GA_VERS already installed"
    return
fi
echo "Installing VirtualBox Guest Additions v$VBOX_GA_VERS..."
apt-get -qy remove virtualbox-\*
apt-get -qy purge virtualbox-\*
apt-get -qy install build-essential linux-headers-generic dkms
mkdir /media/vbox_ga_"$VBOX_GA_VERS"
mount -o loop /vagrant/src/vbox_ga_"$VBOX_GA_VERS".iso /media/vbox_ga_"$VBOX_GA_VERS"
export REMOVE_INSTALLATION_DIR=0
sh /media/vbox_ga_"$VBOX_GA_VERS"/VBoxLinuxAdditions.run --nox11
umount /media/vbox_ga_"$VBOX_GA_VERS"
rmdir /media/vbox_ga_"$VBOX_GA_VERS"
touch /var/provision/install-vbox_ga_"$VBOX_GA_VERS"