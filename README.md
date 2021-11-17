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
$ cat db/create_schema.sql| docker-compose exec -T db psql --user postgres -d investing
```

go to [http://[::]:8080 "adminer"](http://[::]:8080)
system: postgres
login and password form .env

Stop and clean:
```shell
$ docker-compose down
$ rm -rf data/postgres
```

Reinstall:
```shell
$ ./full_reinstall.sh
```
