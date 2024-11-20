#!/usr/bin/env bash
set -eu -o pipefail

. scripts/colors.sh
set -x

name="edx-exams"
port="18740"

docker compose up -d lms
docker compose up -d ${name}

# Run migrations
echo -e "${GREEN}Running migrations for ${name}...${NC}"
docker compose exec -T ${name} bash -e -c "cd /edx/app/edx-exams/ && make migrate"

# Create superuser
echo -e "${GREEN}Creating super-user for ${name}...${NC}"
docker compose exec -T ${name} bash -e -c "echo 'from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser(\"edx\", \"edx@example.com\", \"edx\") if not User.objects.filter(username=\"edx\").exists() else None' | python /edx/app/edx-exams/manage.py shell"

# Provision IDA User in LMS and
# create the DOT applications - one for single sign-on and one for backend service IDA-to-IDA authentication.
echo -e "${GREEN}Provisioning ${name}_worker in LMS...${NC}"
./provision-ida-user.sh ${name} ${name} ${port}

make dev.restart-devserver.${name}
