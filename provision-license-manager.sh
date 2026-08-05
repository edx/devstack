#!/usr/bin/env bash
# Provisioning script for the notes service
set -eu -o pipefail

. scripts/colors.sh
set -x

name=license-manager
port=18170

docker compose up -d $name lms

echo -e "${GREEN}Installing requirements for ${name}...${NC}"
docker compose exec -T ${name}  bash -e -c 'cd /edx/app/license_manager/ && make requirements' -- "$name"
# Run migrations
echo -e "${GREEN}Running migrations for ${name}...${NC}"
docker compose exec -T ${name} bash -e -c "cd /edx/app/license_manager/ && make migrate" -- "$name"

# Seed data for development
echo -e "${GREEN}Seeding development data..."
docker compose exec -T ${name} bash -e -c "python manage.py seed_development_data" -- "$name"
# Some migrations require development data to be seeded, hence migrating again.
docker compose exec -T ${name} bash -e -c "make migrate" -- "$name"

# Create superuser
echo -e "${GREEN}Creating super-user for ${name}...${NC}"
docker compose exec -T ${name} bash -e -c "echo 'from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser(\"edx\", \"edx@example.com\", \"edx\") if not User.objects.filter(username=\"edx\").exists() else None' | python /edx/app/license_manager/manage.py shell" -- "$name"

# Provision IDA User in LMS
./provision-ida-user.sh ${name} ${name} $port

# Create system wide enterprise role assignment
# TODO: this is a pretty complex oneline, we should probably eventually convert this to a management command.
echo -e "${GREEN}Creating system wide enterprise user role assignment for ${name}...${NC}"
docker compose exec -T lms bash -e -c "source /edx/app/edxapp/edxapp_env && echo 'from django.contrib.auth import get_user_model; from enterprise.models import SystemWideEnterpriseUserRoleAssignment, SystemWideEnterpriseRole; User = get_user_model(); worker_user = User.objects.get(username=\"${name}_worker\"); operator_role = SystemWideEnterpriseRole.objects.get(name=\"enterprise_openedx_operator\"); assignment = SystemWideEnterpriseUserRoleAssignment.objects.get_or_create(user=worker_user, role=operator_role, applies_to_all_contexts=True);' | /edx/app/edxapp/venvs/edxapp/bin/python /edx/app/edxapp/edx-platform/manage.py lms shell" -- lms

make dev.restart-devserver.license-manager
