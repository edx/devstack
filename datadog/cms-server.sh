#!/bin/bash
# Run the CMS as it would normally run in devstack.

python /edx/app/edxapp/edx-platform/manage.py cms runserver 0.0.0.0:18000 --settings devstack
