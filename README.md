# Track investing profile (tinvestp)

## Intro

Features:

* transactions history
* common result abs and percents
* result by account (asset)
* exchange currency

## Usage

Run:

```shell
$ cp .env.template .env
$ docker-compose up -d
$ docker-compose exec -T db psql --user investing -d investing < db/create_schema.sql
```

go to [http://[::]:8080 "adminer"](http://[::]:8080)
system: postgres login and password form .env

Stop and clean:

```shell
$ docker-compose down
$ rm -rf data/postgres
```

Stop, clean and rerun:

```shell
$ ./full_reinstall.sh
```
