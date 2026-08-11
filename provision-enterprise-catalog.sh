name="enterprise-catalog"
port="18160"

docker compose up -d $name

# Run migrations
echo -e "${GREEN}Running migrations for ${name}...${NC}"
docker compose exec -T ${name} bash -c "cd /edx/app/${name}/ && make migrate"

echo -e "${GREEN}Installing requirements for ${name}...${NC}"
docker compose exec -T ${name}  bash -e -c 'cd /edx/app/enterprise-catalog/ && make requirements' -- "$name"

# Create superuser
echo -e "${GREEN}Creating super-user for ${name}...${NC}"
docker compose exec -T ${name} bash -c "echo 'from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser(\"edx\", \"edx@example.com\", \"edx\") if not User.objects.filter(username=\"edx\").exists() else None' | python /edx/app/${name}/manage.py shell"

./provision-ida-user.sh ${name} ${name} ${port}

# Create system wide enterprise role assignment
echo -e "${GREEN}Creating system wide enterprise user role assignment for ${name}...${NC}"
docker compose exec -T lms bash -e -c "source /edx/app/edxapp/edxapp_env && python /edx/app/edxapp/edx-platform/manage.py lms --settings=devstack assign_system_wide_enterprise_role --username ${name}_worker --role enterprise_openedx_operator --all-contexts"

# Restart enterprise.catalog app and worker containers
docker compose restart enterprise-catalog enterprise-catalog-worker
