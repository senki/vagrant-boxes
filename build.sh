#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# SEE LICENSE File

do_build() {
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

set -e

if [ $# -eq 0 ]
  then
    do_help
    exit
fi

if [ $1 == "all" ]
  then
    echo "    Building all vagrant boxes"
    BOX_NAME="precise"
    do_build
    BOX_NAME="trusty"
    do_build
elif [ $1 == "precise" ]
  then
    echo "    Building 'precise' vagrant box"
    BOX_NAME="precise"
    do_build
elif [ $1 == "trusty" ]
    then
    echo "    Building 'trusty' vagrant box"
    BOX_NAME="trusty"
    do_build
else
    do_help
fi
