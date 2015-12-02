#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# SEE LICENSE File

set -e

GREEN='\033[1;32m'
NC="\033[0m"

do_build() {
    echo -e "${GREEN}Building ubuntu ${BOX_NAME} tls x64 vagrant box${NC}"
    if [ ! -d "dist" ]
        then
        mkdir dist
    fi
    if [ -f "dist/${BOX_NAME}.box" ]
        then
        rm dist/${BOX_NAME}.box
    fi
    vagrant up ${BOX_NAME} --provision
    vagrant package ${BOX_NAME} --output dist/${BOX_NAME}.box
    vagrant box add src/${BOX_NAME}.json
    rm dist/${BOX_NAME}.box
    vagrant destroy -f
}

do_help() {
    echo "Argument missing or invalid!"
    echo ""
    echo "Usage: build.sh <subcommand>"
    echo ""
    echo "Available subcommands:"
    echo "    all            Building all vagrant boxes"
    echo "    precise        Building 'precise64' vagrant box"
    echo "    trusty         Building 'trusty64' vagrant box"
    echo ""
}

if [ $# -eq 0 ]
  then
    do_help
    exit
fi

if [ $1 == "all" ]
  then
    BOX_NAME="precise"
    do_build
    BOX_NAME="trusty"
    do_build
elif [ $1 == "precise" ]
  then
    BOX_NAME="precise"
    do_build
elif [ $1 == "trusty" ]
    then
    BOX_NAME="trusty"
    do_build
else
    do_help
    exit
fi
echo -e "${GREEN}build.sh done${NC}"
