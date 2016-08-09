#!/usr/bin/env bash

# Copyright (c) 2016 Csaba Maulis
#
# SEE LICENSE File

set -e
if [ $# -lt 1 ]; then
    echo "You need specify a GA versions!"
    echo "    Like: $0 4.1.5"
    exit
fi

VBOX_GA_VERS="$1"

if [[ ! -f "src/vbox_ga_$VBOX_GA_VERS.iso" ]]; then
  echo -e "Downloading VirtualBox Guest Additions v$VBOX_GA_VERS..."
    rm src/vbox_ga_*
    curl -L -o src/vbox_ga_$VBOX_GA_VERS.iso http://download.virtualbox.org/virtualbox/$VBOX_GA_VERS/VBoxGuestAdditions_$VBOX_GA_VERS.iso
else
    echo -e "VirtualBox Guest Additions up-to-date: v$VBOX_GA_VERS"
fi

echo -e "Done"
