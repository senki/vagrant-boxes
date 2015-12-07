#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# SEE LICENSE File

set -e

GREEN='\033[1;32m'
YELLOW='\033[0;33m'
RED='\033[1;31m'
NC="\033[0m"

do_test() {
    echo -e "${GREEN}Destroying previously ubuntu ${BOX_NAME} tls x64 test box - if any${NC}"
    vagrant destroy ${BOX_NAME}_test -f
    echo -e "${GREEN}Building ubuntu ${BOX_NAME} tls x64 test box${NC}"
    vagrant up ${BOX_NAME}_test --provision
    find ./log -mtime +1 -type f -delete
    LOGFILE=$(
        find ./log -type f |
        sort -t '-' -k3nr -k4nr -k5nr -k6nr -k7nr -k8nr |
        head -1
    )
    echo -e  "${YELLOW}Logfile: ${LOGFILE}${NC}"
    echo -ne "${YELLOW}Problem: "
    if grep -i -e warning -e error -e fail -e unable $LOGFILE |
    grep -vc -e error.o -e error-pages -e "unable to re-open stdin" -e "key_buffer instead of key_buffer_size"; then
        echo -e "${RED}Logfile has error(s), aborting!${NC}"
        echo "    All foundigs:"
        grep -i -e warning -e error -e fail -e unable $LOGFILE
        exit
    else
        echo -e "${GREEN}No unknown errors in logfile${NC}"
    fi
    open "http://lamp-${BOX_NAME}-test.local"
}

do_help() {
    echo "Argument missing or invalid!"
    echo ""
    echo "Usage: test.sh <subcommand>"
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
