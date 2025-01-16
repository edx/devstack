#!/bin/bash
# Run the Discovery as it would normally run in devstack.

python /edx/app/discovery/discovery/manage.py runserver 0.0.0.0:18381
