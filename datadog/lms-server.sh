#!/bin/bash
# Run the LMS as it would normally run in devstack.

python /edx/app/edxapp/edx-platform/manage.py lms runserver 0.0.0.0:18000 --settings devstack
