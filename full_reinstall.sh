#!/bin/sh

. .env

docker-compose down && rm -rf data/postgres
docker-compose up -d
RETRIES=5
until docker-compose exec db psql --user $POSTGRES_USER -d postgres -c "select 1" > /dev/null 2>&1 || [ $RETRIES -eq 0 ]; do
    echo "Waiting postgres..."
    sleep 1
done

docker-compose exec -T db psql --user $POSTGRES_USER -d $POSTGRES_DB < db/create_schema.sql
docker-compose exec -T db psql --user $POSTGRES_USER -d $POSTGRES_DB < db/sample/all.sql
