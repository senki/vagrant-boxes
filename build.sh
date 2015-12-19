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

do_build() {
    echo -e "${GREEN}Building ubuntu ${BOX_NAME} tls x64 vagrant box${NC}"
    find ./vagrant/db -type f \( ! -iname "*.gitignore" \) -delete
    set +e
    vagrant box remove senki/$(echo ${BOX_NAME//_/-}) -f
    set -e
    vagrant destroy ${BOX_NAME} -f
    vagrant up ${BOX_NAME}
    do_logcheck
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
    echo "Usage: $0 [subcommand]"
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

case $1 in
    all)
        BOX_NAME="precise"
        do_build
        BOX_NAME="trusty"
        do_build
        BOX_NAME="trusty_php7"
        do_build
        ;;
    precise|trusty|trusty_php7)
        BOX_NAME="${1}"
        do_build
        ;;
    *)
        echo "Argument missing or invalid! Exiting"
        exit 1
        ;;
esac

echo -e "${GREEN}build.sh done${NC}"
