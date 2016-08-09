#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# SEE LICENSE File

set -e

GREEN="\033[1;32m"
YELLOW="\033[0;33m"
RED="\033[1;31m"
NC="\033[0m"
BOXADD=false

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

main_test() {
  echo -e "${GREEN}Destroying previously ubuntu ${BOX_NAME} tls x64 test box - if any${NC}"
  find ./vagrant/db -type f \( ! -iname "*.gitignore" \) -delete
  vagrant destroy ${BOX_NAME}_test -f
  echo -e "${GREEN}Building ubuntu ${BOX_NAME} tls x64 test box${NC}"
  vagrant up ${BOX_NAME}_test --provision
  do_logcheck
  open "http://senki-$(echo ${BOX_NAME//_/-})-test.local"
}

main_build() {
    echo -e "${GREEN}Building ubuntu ${BOX_NAME} tls x64 vagrant box${NC}"
    find ./vagrant/db -type f \( ! -iname "*.gitignore" \) -delete
    if [[ BOXADD ]]; then
      set +e
      vagrant box remove senki/$(echo ${BOX_NAME//_/-}) -f
      set -e
    fi
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
    if [[ BOXADD ]]; then
      vagrant box add src/${BOX_NAME}.json
      rm dist/${BOX_NAME}.box
      vagrant destroy ${BOX_NAME} -f
    fi
}

do_help() {
    echo "Argument missing or invalid!"
    echo ""
    echo "Usage: $0 [subcommand] [target]"
    echo ""
    echo "Available subcommands:"
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

if [ $# -lt 2 ]; then
    do_help
    exit
fi

case $1 in
    test)
        PROCESS="test"
        ;;
    build)
        PROCESS="build"
        ;;
    add)
        PROCESS="build"
        BOXADD=true
        ;;
    *)
        echo "Argument missing or invalid! Exiting"
        exit 1
        ;;
esac

case $2 in
    all)
        BOX_NAME="precise"
        main_$PROCESS
        BOX_NAME="trusty"
        main_$PROCESS
        ;;
    precise|trusty)
        BOX_NAME="${2}"
        main_$PROCESS
        ;;
    *)
        echo "Argument missing or invalid! Exiting"
        exit 1
        ;;
esac

echo -e "${GREEN}${0} done${NC}"
