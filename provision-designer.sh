name="designer"
port="18808"

docker compose up -d $name --build
docker compose up -d lms

# Install requirements
# Can be skipped right now because we're using the --build flag on docker compose. This will need to be changed once we move to devstack.

# Wait for MySQL
echo "Waiting for MySQL"
until docker exec -i edx.devstack.mysql80 mysql -u root -se "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = 'root')" &> /dev/null
do
  printf "."
  sleep 1
done
sleep 5

echo -e "${GREEN}Installing requirements for ${name}...${NC}"
docker compose exec -T ${name}  bash -e -c 'cd /edx/app/designer/ && make requirements' -- f"$name"

# Run migrations
echo -e "${GREEN}Running migrations for ${name}...${NC}"
docker compose exec -T ${name}  bash -e -c -c "cd /edx/app/${name}/ && make migrate"

# Create superuser
echo -e "${GREEN}Creating super-user for ${name}...${NC}"
docker compose exec -T ${name}  bash -e -c -c "echo 'from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser(\"edx\", \"edx@example.com\", \"edx\") if not User.objects.filter(username=\"edx\").exists() else None' | python /edx/app/${name}/manage.py shell"

./provision-ida-user.sh ${name} ${name} ${port}

# Restart designer app
make dev.restart-devserver.designer
