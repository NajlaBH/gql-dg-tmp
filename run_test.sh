#!/bin/bash

# Setup for returning a non-zero exit code if any of the command fails.
err=0
trap 'err=1' ERR

# Clean
if psql -lqt | cut -d \| -f 1 | grep -qw bestwishesdb ; then
    read -p "Database 'bestwishesdb' required for running the tests already exist. Do you want to delete it (y)?" yn
    if echo "$yn" | grep -iq "^n" ;then
        exit
    else
        dropdb bestwishesdb
    fi
fi

rm -rf ./gql-dg-tmp;

#Create db demo-credits for travis
psql -c "CREATE DATABASE bestwishesdb;"
psql -c "CREATE USER happuser WITH ENCRYPTED PASSWORD 'newypass';"
psql -c "ALTER ROLE happuser SET client_encoding TO 'utf8';"
psql -c "ALTER ROLE happuser SET default_transaction_isolation TO 'read committed';"
psql -c "ALTER ROLE happuser SET timezone TO 'UTC';"
psql -c "GRANT ALL PRIVILEGES ON DATABASE bestwishesdb TO happuser;"
#CircleCi user grant
psql -c "CREATE USER circleci WITH ENCRYPTED PASSWORD 'circleci';"
psql -c "ALTER ROLE circleci SET client_encoding TO 'utf8';"
psql -c "ALTER ROLE circleci SET default_transaction_isolation TO 'read committed';"
psql -c "ALTER ROLE circleci SET timezone TO 'UTC';"
psql -c "GRANT ALL PRIVILEGES ON DATABASE bestwishesdb TO circleci;"

# Run the tests present inside generate project
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py test

# Cleanup
test ! $CI && dropdb bestwishesdb

test $err = 0 # Return non-zero if any command failed
