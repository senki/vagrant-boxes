#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# SEE LICENSE File

set -e

GREEN="\033[1;32m"
YELLOW="\033[0;33m"
RED="\033[1;31m"
NC="\033[0m"
ISTEST=false

do_logcheck() {
    find ./vagrant/log -type f \( ! -iname "*.gitignore" \) -mtime +1 -delete
    LOGFILE=$(
        find ./vagrant/log -type f |
        sort -t '-' -k3nr -k4nr -k5nr -k6nr -k7nr -k8nr |
        head -1
    )
    echo -e  "${YELLOW}Logfile: ${LOGFILE}${NC}"
    echo -ne "${YELLOW}Problem: "
    if grep -i \
            -e warning \
            -e error \
            -e fail \
            -e unable \
            $LOGFILE |
        grep -vc \
            -e error.o \
            -e error-pages \
            -e "preconfigure: unable to re-open stdin" \
            -e "No error reported" \
            -e "TIMESTAMP with implicit DEFAULT value is deprecated" \
            -e "key_buffer instead of key_buffer_size" \
            -e "while removing linux-headers"
      then
        echo -e "${RED}Logfile has error(s), aborting!${NC}"
        echo "    All foundigs:"
        grep -i -e warning -e error -e fail -e unable $LOGFILE
        exit
    else
        echo -e "${GREEN}No unknown errors in logfile${NC}"
    fi
}

do_destroy() {
  echo -e "${GREEN}Destroying previously ubuntu ${BOX_NAME} tls x64 box - if any${NC}"
  vagrant destroy ${BOX_NAME} -f
  vagrant destroy ${BOX_NAME}_test -f
  }

do_build() {
  echo -e "${GREEN}Building ubuntu ${BOX_NAME} tls x64 box${NC}"
  if $ISTEST ; then
    vagrant up ${BOX_NAME}_test --provision
  else
    vagrant up ${BOX_NAME} --provision
  fi
  do_logcheck
  if $ISTEST ; then
    open "http://senki-$(echo ${BOX_NAME//_/-})-test.local"
  fi
}

do_add() {
    echo -e "${GREEN}Adding ubuntu ${BOX_NAME} tls x64 vagrant box${NC}"
    set +e
    vagrant box remove senki/$(echo ${BOX_NAME//_/-}) -f
    set -e
    if [ ! -d "dist" ]; then
        mkdir dist
    fi
    if [ -f "dist/${BOX_NAME}.box" ]; then
        rm dist/${BOX_NAME}.box
    fi
    vagrant package ${BOX_NAME} --output dist/${BOX_NAME}.box
    vagrant box add src/${BOX_NAME}.json
    rm dist/${BOX_NAME}.box
}

do_help() {
    echo "Argument missing or invalid!"
    echo ""
    echo "Usage: $0 [subcommand] [target]"
    echo ""
    echo "Available subcommands:"
    echo "    destroy        Destroy previously created boxes"
    echo "    test           Recereate and running test boxes"
    echo "    build          Build vagrant boxes"
    echo "    add            Removing previous, rebuilding & adding new boxes"
    echo "                   This deletes '.box' file after publish"
    echo ""
    echo "Available targets:"
    echo "    all            Select all boxes"
    echo "    precise        Select 'precise' x64 box"
    echo "    trusty         Select 'trusty' x64 box"
    echo ""
}

# start here

if [ $# -lt 2 ]; then
    do_help
    exit
fi

find ./vagrant/db -type f \( ! -iname "*.gitignore" \) -delete

case $1 in
    destroy)
        PROCESS="destroy"
        ;;
    test)
        PROCESS="build"
        ISTEST=true
        ;;
    build)
        PROCESS="build"
        ;;
    add)
        PROCESS="add"
        ;;
    *)
        echo "Argument missing or invalid! Exiting"
        exit 1
        ;;
esac

case $2 in
    all)
        BOX_NAME="precise"
        do_$PROCESS
        BOX_NAME="trusty"
        do_$PROCESS
        ;;
    precise|trusty)
        BOX_NAME="${2}"
        do_$PROCESS
        ;;
    *)
        echo "Argument missing or invalid! Exiting"
        exit 1
        ;;
esac

echo -e "${GREEN}${0} done${NC}"
