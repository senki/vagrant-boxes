#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# SEE LICENSE File




do_logcheck() {
    find ./vagrant/log -mtime +1 -type f -delete
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
            -e "key_buffer instead of key_buffer_size"
      then
        echo -e "${RED}Logfile has error(s), aborting!${NC}"
        echo "    All foundigs:"
        grep -i -e warning -e error -e fail -e unable $LOGFILE
        exit
    else
        echo -e "${GREEN}No unknown errors in logfile${NC}"
    fi
}

