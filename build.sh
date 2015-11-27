#!/usr/bin/env bash

# Copyright (c) 2015 Csaba Maulis
#
# The MIT License (MIT)

echo "+ mkdir dist"
mkdir dist
echo "+ rm dist/*.box"
rm dist/*.box
echo "+ vagrant up"
vagrant up
echo "+ vagrant halt"
vagrant halt
echo "+ vagrant package precise --output dist/precise.box"
vagrant package precise --output dist/precise.box
echo "+ vagrant package trusty --output dist/trusty.box"
vagrant package trusty --output dist/trusty.box
echo "+ vagrant box add src/precise.json"
vagrant box add src/precise.json
echo "+ vagrant box add src/trusty.json"
vagrant box add src/trusty.json
echo "+ rm dist/*.box"
rm dist/*.box
