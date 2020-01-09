#!/bin/bash

# Setup for returning a non-zero exit code if any of the command fails.
err=0
trap 'err=1' ERR

# Clean
if psql -lqt | cut -d \| -f 1 | grep -qw circle_test ; then
    read -p "Database 'circle_test' required for running the tests already exist. Do you want to delete it (y)?" yn
    if echo "$yn" | grep -iq "^n" ;then
        exit
    else
        dropdb circle_test
    fi
fi

rm -rf ./gql-dg-tmp;

#Create db demo-credits for travis
psql -c "CREATE DATABASE circle_test;"
psql -c "CREATE USER root WITH ENCRYPTED PASSWORD '';"
psql -c "ALTER ROLE root SET client_encoding TO 'utf8';"
psql -c "ALTER ROLE root SET default_transaction_isolation TO 'read committed';"
psql -c "ALTER ROLE root SET timezone TO 'UTC';"
psql -c "GRANT ALL PRIVILEGES ON DATABASE circle_test TO root;"
#CircleCi user grant
psql -c "CREATE USER circleci WITH ENCRYPTED PASSWORD 'circleci';"
psql -c "ALTER ROLE circleci SET client_encoding TO 'utf8';"
psql -c "ALTER ROLE circleci SET default_transaction_isolation TO 'read committed';"
psql -c "ALTER ROLE circleci SET timezone TO 'UTC';"
psql -c "GRANT ALL PRIVILEGES ON DATABASE circle_test TO circleci;"

# Run the tests present inside generate project
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py test

# Cleanup
test ! $CI && dropdb bestwishesdb

test $err = 0 # Return non-zero if any command failed
