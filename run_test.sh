#!/bin/bash

# Setup for returning a non-zero exit code if any of the command fails.
err=0
trap 'err=1' ERR

# Clean
if psql -lqt | cut -d \| -f 1 | grep -qw bestwishesdb ; then
    read -p "Database 'best_wishes' required for running the tests already exist. Do you want to delete it (y)?" yn
    if echo "$yn" | grep -iq "^n" ;then
        exit
    else
        dropdb bestwishesdb
    fi
fi

rm -rf ./gql-dg-tmp;



# Run the tests present inside generate project
cd ./gql-dg-tmp;
python3 -m venv venv
source venv/bin/activate

# Cleanup
test ! $CI && dropdb bestwishesdb

test $err = 0 # Return non-zero if any command failed
