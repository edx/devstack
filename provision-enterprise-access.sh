set -euf -o pipefail

. scripts/colors.sh

name="enterprise-access"
port="18270"

docker compose up -d $name lms

echo -e "${GREEN}Installing requirements for ${name}...${NC}"
docker compose exec -T ${name}  bash -e -c 'cd /edx/app/enterprise-access && make requirements' -- "$name"

# Run migrations
echo -e "${GREEN}Running migrations for ${name}...${NC}"
docker compose exec -T ${name} bash -e -c "cd /edx/app/enterprise-access/ && make migrate" -- "$name"
# docker compose exec -T ${name} bash -e -c 'source /edx/app/credentials/credentials_env && cd /edx/app/credentials/credentials && make migrate' -- "$name"

# Create superuser
echo -e "${GREEN}Creating super-user for ${name}...${NC}"
docker compose exec -T ${name} bash -e -c "echo 'from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser(\"edx\", \"edx@example.com\", \"edx\") if not User.objects.filter(username=\"edx\").exists() else None' | python /edx/app/enterprise-access/manage.py shell" -- "$name"

./provision-ida-user.sh ${name} ${name} ${port}

# Create system wide enterprise role assignment
echo -e "${GREEN}Creating system wide enterprise user role assignment for ${name}...${NC}"
docker compose exec -T lms bash -e -c "source /edx/app/edxapp/edxapp_env && python /edx/app/edxapp/edx-platform/manage.py lms --settings=devstack assign_system_wide_enterprise_role --username ${name}_worker --role enterprise_openedx_operator --all-contexts"

make dev.restart-devserver.enterprise-access
