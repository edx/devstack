#!/usr/bin/env bash
set -eu -o pipefail
set -x

. scripts/colors.sh

name="enterprise-subsidy"
port="18280"

docker compose up -d ${name} lms

# Run migrations
echo -e "${GREEN}Running migrations for ${name}...${NC}"
docker compose exec ${name} bash -c "cd /edx/app/${name}/ && make migrate"

# Create superuser
echo -e "${GREEN}Creating super-user for ${name}...${NC}"
docker compose exec ${name} bash -c "echo 'from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser(\"edx\", \"edx@example.com\", \"edx\") if not User.objects.filter(username=\"edx\").exists() else None' | python /edx/app/${name}/manage.py shell"

# Provision IDA User in LMS
echo -e "${GREEN}Provisioning ${name}_worker in LMS...${NC}"

./provision-ida-user.sh ${name} ${name} ${port}

# Create system wide enterprise role assignment
# TODO: this is a pretty complex oneline, we should probably eventually convert this to a management command.
echo -e "${GREEN}Creating system wide enterprise user role assignment for ${name}...${NC}"
docker compose exec -T lms bash -e -c "source /edx/app/edxapp/edxapp_env && echo 'from django.contrib.auth import get_user_model; from enterprise.models import SystemWideEnterpriseUserRoleAssignment, SystemWideEnterpriseRole; User = get_user_model(); worker_user = User.objects.get(username=\"${name}_worker\"); operator_role = SystemWideEnterpriseRole.objects.get(name=\"enterprise_openedx_operator\"); assignment = SystemWideEnterpriseUserRoleAssignment.objects.get_or_create(user=worker_user, role=operator_role, applies_to_all_contexts=True);' | /edx/app/edxapp/venvs/edxapp/bin/python /edx/app/edxapp/edx-platform/manage.py lms shell" -- lms

make dev.restart-devserver.enterprise-subsidy
