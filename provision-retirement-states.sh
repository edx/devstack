#!/usr/bin/env bash
#This script depends on the LMS being up!
set -eu -o pipefail

. scripts/colors.sh
set -x

echo -e "${GREEN}Creating retirement states...${NC}"
docker compose exec -T lms  bash -e -c 'source /edx/app/edxapp/edxapp_env && python /edx/app/edxapp/edx-platform/manage.py lms --settings=devstack populate_retirement_states'
