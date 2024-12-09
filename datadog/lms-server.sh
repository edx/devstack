#!/bin/bash
# Run the LMS as it would normally run in devstack.

#python /edx/app/edxapp/edx-platform/manage.py lms runserver 0.0.0.0:18000 --settings devstack

SERVICE_VARIANT=lms
SERVICE_PORT=18000

export DJANGO_SETTINGS_MODULE=${SERVICE_VARIANT}.envs.devstack
gunicorn \
    -c /edx/app/edxapp/edx-platform/${SERVICE_VARIANT}/docker_${SERVICE_VARIANT}_gunicorn.py \
    --name ${SERVICE_VARIANT} \
    --bind=0.0.0.0:${SERVICE_PORT} \
    --max-requests=1000 \
    --access-logfile \
    - ${SERVICE_VARIANT}.wsgi:application
