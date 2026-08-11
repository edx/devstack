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
echo -e "${GREEN}Creating system wide enterprise user role assignment for ${name}...${NC}"
docker compose exec -T lms bash -e -c "source /edx/app/edxapp/edxapp_env && python /edx/app/edxapp/edx-platform/manage.py lms --settings=devstack assign_system_wide_enterprise_role --username ${name}_worker --role enterprise_openedx_operator --all-contexts"

make dev.restart-devserver.license-manager
