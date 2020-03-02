#!/bin/bash
  
# Setup for returning a non-zero exit code if any of the command fails.
err=0
trap 'err=1' ERR


#Run the tests present inside generate project
python3 -m venv env
source env/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
#python manage.py migrate


#Run tests
python manage.py test


# Cleanup
test ! $CI && dropdb circle_test

test $err = 0 # Return non-zero if any command failed
