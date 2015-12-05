#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# SEE LICENSE File

set -e

GREEN='\033[1;32m'
NC="\033[0m"

do_test() {
    echo -e "${GREEN}Destroying previously ubuntu ${BOX_NAME} tls x64 test box - if any${NC}"
    vagrant destroy ${BOX_NAME}_test -f
    echo -e "${GREEN}Building ubuntu ${BOX_NAME} tls x64 test box${NC}"
    vagrant up ${BOX_NAME}_test --provision
    open "http://lamp-${BOX_NAME}-test.local"
}

do_help() {
    echo "Argument missing or invalid!"
    echo ""
    echo "Usage: build.sh <subcommand>"
    echo ""
    echo "Available subcommands:"
    echo "    all            Building all test boxes"
    echo "    precise        Building 'precise64' test box"
    echo "    trusty         Building 'trusty64' test box"
    echo ""
}

set -e

if [ $# -eq 0 ]; then
    do_help
    exit
fi

if [ $1 == "all" ]; then
    BOX_NAME="precise"
    do_test
    BOX_NAME="trusty"
    do_test
elif [ $1 == "precise" ]; then
    BOX_NAME="precise"
    do_test
elif [ $1 == "trusty" ]; then
    BOX_NAME="trusty"
    do_test
else
    do_help
    exit
fi
echo -e "${GREEN}test.sh done${NC}"
