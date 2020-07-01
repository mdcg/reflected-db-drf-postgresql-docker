#!/bin/sh
# Setting up env variables:
set -a
. config/.env
set +a

DATABASE_DUMP_PATH=$1
DATABASE_DUMP_FILENAME=${DATABASE_DUMP_PATH##*/}
POSTGRES_CONTAINER_ID=$(docker ps -aqf "name=db")
DJANGO_PROJECT_CONTAINER_ID=$(docker ps -aqf "name=reflected_dev")
POSTGRES_DUMP_PATH="/var/lib/postgresql/data"

echo "PostgreSQL Container ID: ${POSTGRES_CONTAINER_ID}"
echo "PostgreSQL Path of the file to restore: ${POSTGRES_DUMP_PATH}"
echo "PostgreSQL User: ${POSTGRES_USER}"
echo "PostgreSQL DB: ${POSTGRES_DB}"
echo "Backup filename path: ${DATABASE_DUMP_PATH}"
echo "Backup filename: ${DATABASE_DUMP_FILENAME}"

echo "Copying file ${DATABASE_DUMP_PATH} to the Docker container at ${POSTGRES_DUMP_PATH}."
echo "This command may take a while to depend on the size of the backup file, so please wait."
docker cp ${DATABASE_DUMP_PATH} ${POSTGRES_CONTAINER_ID}:${POSTGRES_DUMP_PATH}

echo "Initializing database restoration process."
echo "Again, depending on the size of the backup file, this command may also take a few minutes, so please wait." 
docker exec -it ${POSTGRES_CONTAINER_ID} sh -c "psql -U ${POSTGRES_USER} -d ${POSTGRES_DB} < ${POSTGRES_DUMP_PATH}/${DATABASE_DUMP_FILENAME}"
docker exec -it ${POSTGRES_CONTAINER_ID} sh -c "rm ${POSTGRES_DUMP_PATH}/${DATABASE_DUMP_FILENAME}"

echo "Generating models from the database restored in the Django project."
docker exec -it ${DJANGO_PROJECT_CONTAINER_ID} sh -c "python src/manage.py inspectdb > src/api/models.py"

echo "Done!!"