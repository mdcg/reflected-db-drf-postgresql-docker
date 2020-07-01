# Reflected DB - Django REST FRAMEWORK + PostgreSQL + Docker - Example

[![GitHub](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/mdcg/reflected-database-drf-api/blob/master/LICENSE)

In case you need to generate your models in Django from a PostgreSQL database backup, here you will have the necessary tools to achieve this goal!

First of all, you will need to configure your environment variables that will be used both for creating the PostgreSQL and DRF project containers, as well as for restoring the backup and creating the models. To do this, go to the `config` folder and run the following commands:

```
cp .env-example .env
```

The above command will copy the contents of `.env-example` to a new` .env` file. Now open the `.env` file and assign the corresponding values ​​to each of the variables. I'm not going to stick to the security aspects too much, since you will most likely generate the models under development, but for practical purposes, it is interesting that both the user and the password, established by the `POSTGRES_USER` and` POSTGRES_PASSWORD` variables, are ` postgres`.

In the `POSTGRES_HOST` variable, the` db` value is already pre-established. This value corresponds to the name of the PostgreSQL container so for now is not necessary to change, but if you do, make sure to change the name of the container in the `docker-compose.yml` file as well.

Now that we have set up our environment variables, we need to initialize the PostgreSQL and DRF project containers. To do this, run the following command:


```
docker-compose up
```

This command may take a while, so be patient. When everything is working, you will probably see a stdout that looks like this:

```
.
.
.
reflected_dev_1  | Performing system checks...
reflected_dev_1  | 
reflected_dev_1  | System check identified no issues (0 silenced).
reflected_dev_1  | July 01, 2020 - 17:30:35
reflected_dev_1  | Django version 3.0.7, using settings 'core.settings'
reflected_dev_1  | Starting development server at http://0.0.0.0:8000/
reflected_dev_1  | Quit the server with CONTROL-C.
```

Nice! Our containers are working. Now we just need to restore the backup and generate our models. For this, there is a script called `reflect_db.sh` in the project's root directory, which will do all the magic. Make sure you have the backup file with you (usually this file has the extension `.sql`).

With the backup file, you will need to give execute permission to `reflect_db.sh`, to do this run the following command: 

```
chmod +x reflect_db.sh
```

Now to restore the backup of the PostgreSQL database and generate Django models from it, just run the following command:

```
./reflect_db.sh <path_to_backup_file/backup_file.sql>
```

To further improve the example, imagine that the name of my backup file is `backup.sql` (very creative) and the path to it is` /home/mdcg/dev/`, so the command would look like this:

```
./reflect_db.sh /home/mdcg/dev/backup.sql
```

Depending on the size of the backup file, the above command may take considerable minutes, but again, be patient. At the end of the process, go to the `models.py` file located in` src/api/ `and see if the models were generated.

## Contributing

This project is under the [MIT license](https://github.com/mdcg/reflected-database-drf-api/blob/master/LICENSE). Feel free to do whatever you want with this project. :-)