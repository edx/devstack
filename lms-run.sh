#!/bin/bash
# LMS runner script to support both normal and debug modes
# Usage: lms-run.sh [debug|normal]
# Expected to be run inside the LMS container

set -e

source /edx/app/edxapp/edxapp_env

DEBUG_MODE="${1:-${DEVSTACK_DEBUG:-normal}}"

# Install pip requirements
pip install -r /edx/private_requirements.txt

if [ "$DEBUG_MODE" = "debug" ]; then
    # Install debugpy for debug mode
    pip install debugpy
    
    # Run with debugpy
    while true; do
        python -m debugpy --listen 0.0.0.0:44568 --wait-for-client \
            /edx/app/edxapp/edx-platform/manage.py lms runserver 0.0.0.0:18000 \
            --settings devstack --noreload
        sleep 2
    done
else
    # Run in normal mode
    while true; do
        python /edx/app/edxapp/edx-platform/manage.py lms runserver 0.0.0.0:18000 \
            --settings devstack --noreload
        sleep 2
    done
fi
