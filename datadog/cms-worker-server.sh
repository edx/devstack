#!/bin/bash
# Run the CMS as it would normally run in devstack.


# cms-server changes for reference:

# before:
# command: bash -c 'source /edx/app/edxapp/edxapp_env && while true; do python /edx/app/edxapp/edx-platform/manage.py lms runserver 0.0.0.0:18000 --settings devstack; sleep 2; done'
# PATH: "/edx/app/edxapp/venvs/edxapp/bin:/edx/app/edxapp/nodeenv/bin:/edx/app/edxapp/edx-platform/node_modules/.bin:/edx/app/edxapp/edx-platform/bin:${PATH}"

# after:
# python /edx/app/edxapp/edx-platform/manage.py cms runserver 0.0.0.0:18010 --settings devstack_with_worker
# PATH: "/edx/app/edxapp/venvs/edxapp/bin:/edx/app/edxapp/nodeenv/bin:/edx/app/edxapp/edx-platform/node_modules/.bin:/edx/app/edxapp/edx-platform/bin:/edx/datadog:${PATH}"

# cms-worker-server changes:
# command: bash -c 'source /edx/app/edxapp/edxapp_env && cd /edx/app/edxapp/edx-platform && celery --app=cms.celery:APP worker -l debug -c 2'
celery --app=cms.celery:APP worker -l debug -c 2 &
