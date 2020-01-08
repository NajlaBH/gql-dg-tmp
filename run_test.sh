#!/bin/bash

# Setup for returning a non-zero exit code if any of the command fails.
err=0
trap 'err=1' ERR

# Clean
if psql -lqt | cut -d \| -f 1 | grep -qw best_wishes ; then
    read -p "Database 'best_wishes' required for running the tests already exist. Do you want to delete it (y)?" yn
    if echo "$yn" | grep -iq "^n" ;then
        exit
    else
        dropdb best_wishes
    fi
fi

rm -rf gqt-dg-tmp/;

# Generate new code, (it also creates db, migrate and install dependencies)
yes 'y' | cookiecutter . --no-input

# Run the tests present inside generate project
cd gqt-dg-tmp;
npm run build
source venv/bin/activate
ansible-playbook -i provisioner/hosts provisioner/site.yml --syntax-check
fab test:"--cov"

# Cleanup
test ! $CI && dropdb best_wishes

test $err = 0 # Return non-zero if any command failed
