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

#Create db
sudo service postgresql start
sudo -u postgres psql
CREATE DATABASE bestwishesdb;
CREATE USER happuser WITH ENCRYPTED PASSWORD 'newypass';
ALTER ROLE happuser SET client_encoding TO 'utf8';
ALTER ROLE happuser SET default_transaction_isolation TO 'read committed';
ALTER ROLE happuser SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE bestwishesdb TO happuser;
\q

# Run the tests present inside generate project
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python manage.py runserver

# Cleanup
test ! $CI && dropdb bestwishesdb

test $err = 0 # Return non-zero if any command failed
