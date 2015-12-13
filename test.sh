#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# SEE LICENSE File

set -e

GREEN="\033[1;32m"
YELLOW="\033[0;33m"
RED="\033[1;31m"
NC="\033[0m"

source src/logcheck.sh

do_test() {
    echo -e "${GREEN}Destroying previously ubuntu ${BOX_NAME} tls x64 test box - if any${NC}"
    vagrant destroy ${BOX_NAME}_test -f
    echo -e "${GREEN}Building ubuntu ${BOX_NAME} tls x64 test box${NC}"
    vagrant up ${BOX_NAME}_test --provision
    do_logcheck
    open "http://senki-$(echo ${BOX_NAME//_/-})-test.local"
}

do_help() {
    echo "Argument missing or invalid!"
    echo ""
    echo "Usage: $0 [subcommand]"
    echo ""
    echo "Available subcommands:"
    echo "    all            Building all test boxes"
    echo "    precise        Building 'precise64' test box"
    echo "    trusty         Building 'trusty64' test box"
    echo "    trusty_php7    Building 'trusty64' with PHP 7 test box"
    echo ""
}

if [ $# -eq 0 ]; then
    do_help
    exit
fi

case $1 in
    all)
        BOX_NAME="precise"
        do_test
        BOX_NAME="trusty"
        do_test
        BOX_NAME="trusty_php7"
        do_test
        ;;
    precise|trusty|trusty_php7)
        BOX_NAME="${1}"
        do_test
        ;;
    *)
        echo "Argument missing or invalid! Exiting"
        exit 1
        ;;
esac

echo -e "${GREEN}test.sh done${NC}"
