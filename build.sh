#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# SEE LICENSE File

set -e

GREEN='\033[1;32m'
YELLOW='\033[0;33m'
RED='\033[1;31m'
NC="\033[0m"

do_build() {
    echo -e "${GREEN}Building ubuntu ${BOX_NAME} tls x64 vagrant box${NC}"
    vagrant box remove senki/${BOX_NAME} -f
    vagrant destroy ${BOX_NAME} -f
    vagrant up ${BOX_NAME}
    find ./vagrant/log -mtime +1 -type f -delete
    LOGFILE=$(
        find ./vagrant/log -type f |
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
    if [ ! -d "dist" ]; then
        mkdir dist
    fi
    if [ -f "dist/${BOX_NAME}.box" ]; then
        rm dist/${BOX_NAME}.box
    fi
    vagrant package ${BOX_NAME} --output dist/${BOX_NAME}.box
    vagrant box add src/${BOX_NAME}.json
    rm dist/${BOX_NAME}.box
    vagrant destroy ${BOX_NAME} -f
}

do_help() {
    echo "Argument missing or invalid!"
    echo ""
    echo "Usage: $0 <subcommand>"
    echo ""
    echo "Available subcommands:"
    echo "    all            Building all vagrant boxes"
    echo "    precise        Building 'precise' x64 vagrant box"
    echo "    trusty         Building 'trusty' x64 vagrant box"
    echo "    trusty_php7    Building 'trusty' x64 with PHP v7 vagrant box"
    echo ""
}

if [ $# -eq 0 ]; then
    do_help
    exit
fi

if [ $1 == "all" ]; then
    BOX_NAME="precise"
    do_build
    BOX_NAME="trusty"
    do_build
    BOX_NAME="trusty_php7"
    do_build
elif [ $1 == "precise" ]; then
    BOX_NAME="precise"
    do_build
elif [ $1 == "trusty" ]; then
    BOX_NAME="trusty"
    do_build
elif [ $1 == "trusty_php7" ]; then
    BOX_NAME="trusty_php7"
    do_build
else
    do_help
    exit
fi
echo -e "${GREEN}build.sh done${NC}"
