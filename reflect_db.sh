#!/bin/sh
# Setting up env variables:
set -a
. config/.env
set +a

DATABASE_DUMP_NAME=$1
CONTAINER_ID=$(docker ps -aqf "name=db")
POSTGRESQL_DUMP_PATH="/var/lib/postgresql/data"

echo "PostgreSQL Container ID: ${CONTAINER_ID}"
echo "PostgreSQL Path of the file to restore: ${POSTGRESQL_DUMP_PATH}"
echo "PostgreSQL User: ${POSTGRES_USER}"
echo "PostgreSQL DB: ${POSTGRES_DB}"
echo "Backup filename: ${DATABASE_DUMP_NAME}"

# docker inspect -f '{{ json .Mounts }}' ${CONTAINER_ID} | python -m json.tool
echo "Copying file ${DATABASE_DUMP_NAME} to the Docker container at ${POSTGRESQL_DUMP_PATH}."
echo "This command may take a while to depend on the size of the backup file, so please wait."
docker cp ${DATABASE_DUMP_NAME} ${CONTAINER_ID}:${POSTGRESQL_DUMP_PATH}

echo "Initializing database restoration process."
echo "Again, depending on the size of the backup file, this command may also take a few minutes, so please wait."
docker exec -it ${CONTAINER_ID} psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} < ${POSTGRESQL_DUMP_PATH}/${DATABASE_DUMP_NAME} && rm ${POSTGRESQL_DUMP_PATH}/${DATABASE_DUMP_NAME}

echo "Generating models from the database restored in the Django project."
python src/manage.py inspectdb > src/api/models.py

echo "Done!!"