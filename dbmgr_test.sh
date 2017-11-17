#!/bin/sh
rm db.sqlite3
rm -rf ../send/*
mkdir ../send/IA02
mkdir ../send/IA03
mkdir ../send/IA04
ruby test_dcmgr.rb
