#!/usr/bin/env bash
set -eu -o pipefail
set -x

. scripts/colors.sh

name="enterprise-subsidy"
port="18280"

docker compose up -d lms
docker compose up -d ${name}

# Run migrations
echo -e "${GREEN}Running migrations for ${name}...${NC}"
docker compose exec ${name} bash -c "cd /edx/app/${name}/ && make migrate"

# Create superuser
echo -e "${GREEN}Creating super-user for ${name}...${NC}"
docker compose exec ${name} bash -c "echo 'from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser(\"edx\", \"edx@example.com\", \"edx\") if not User.objects.filter(username=\"edx\").exists() else None' | python /edx/app/${name}/manage.py shell"

# Provision IDA User in LMS
echo -e "${GREEN}Provisioning ${name}_worker in LMS...${NC}"

./provision-ida-user.sh ${name} ${name} ${port}
