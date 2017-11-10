#!/bin/sh
rm db.sqlite3
rm -rf /home/exports/combu/send/*
mkdir /home/exports/combu/send/send/IA02
mkdir /home/exports/combu/send/send/IA03
mkdir /home/exports/combu/send/send/IA04
ruby test_dcmgr.rb
