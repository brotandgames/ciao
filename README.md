# ciao

**ciao** checks HTTP(S) URL endpoints for a HTTP status code (or errors on the lower TCP stack) and sends an e-mail on status change.

It uses Cron syntax to schedule the checks and comes along with a Web UI and a RESTfull JSON API.

![ciao Checks overview](https://brotandgames.com/assets/ciao-checks.png "ciao Checks overview")
*You can find more screenshots on the [Homepage](https://www.brotandgames.com/ciao/).*

**ciao** (/tʃaʊ/) - **c**heck **i**n **a**nd **o**ut - borrowed from Italian *ciao* for greeting someone.

*Motivation:* create an open source web application for checking URL statuses with an UI and a REST API which is easy to install and maintain (no external dependencies like Databases, Caches etc.) in public and private environments.

## Quickstart

````
docker run --name ciao -p 8090:3000 brotandgames/ciao
````

Open localhost:8090 in your webbrowser.

## Install

You can install ciao via the official Docker image `brotandgames/ciao` or using Git and installing the dependencies manually.

- `SECRET_KEY_BASE` will be auto-generated if you omit it
- You can send emails to several addresses by separating them with a comma eg. `SMTP_EMAIL_TO="a@yourhost.com,b@yourhost.com"`
- By mounting a Docker volume you can avoid loosing data on restart or upgrade
- Time zone is configurable per `TIME_ZONE` variable (default: UTC) eg. `TIME_ZONE="Vienna"` - you can find all possible values by executing `docker run --rm brotandgames/ciao rake time:zones`

IMPORTANT: Be sure to enable authentication (eg. HTTP Basic auth) and TLS certificates if you serve ciao publicly.

### Via Docker image

````
docker run \
  --name ciao \
  -p 8090:3000 \
  -e SECRET_KEY_BASE="sensitive_secret_key_base" \
  -e SMTP_ADDRESS=smtp.yourhost.com \
  -e SMTP_EMAIL_FROM="ciao@yourhost.com" \
  -e SMTP_EMAIL_TO="you@yourhost.com" \
  -e SMTP_PORT=587 \
  -e SMTP_DOMAIN=smtp.yourhost.com \
  -e SMTP_AUTHENTICATION=plain \
  -e SMTP_ENABLE_STARTTLS_AUTO=auto \
  -e SMTP_USERNAME=ciao \
  -e SMTP_PASSWORD="sensitive_password" \
  -v /opt/ciao/data:/app/db/sqlite \
  brotandgames/ciao
````

Open localhost:8090 in your webbrowser.

### Via Docker-compose

Create docker-compose.yml file

````
version: "3"
services:
  ciao:
    image: brotandgames/ciao
    container_name: ciao
    ports:
      - '8090:3000'
    environment:
      - SECRET_KEY_BASE="sensitive_secret_key_base"
      - SMTP_ADDRESS=smtp.yourhost.com
      - SMTP_EMAIL_FROM="ciao@yourhost.com"
      - SMTP_EMAIL_TO="you@yourhost.com"
      - SMTP_PORT=587
      - SMTP_AUTHENTICATION=plain
      - SMTP_DOMAIN=smtp.yourhost.com
      - SMTP_ENABLE_STARTTLS_AUTO=auto
      - SMTP_USERNAME=ciao
      - SMTP_PASSWORD="sensitive_password"
    volumes:
      - /opt/ciao/data:/app/db/sqlite/
````

Pull and run

````
docker-compose pull
docker-compose up -d
````

Open localhost:8090 in the webbrowser.

### Via Git clone

````
# Clone repo
git clone https://github.com/brotandgames/ciao

cd ciao

# Install all dependencies (rubygems)
RAILS_ENV=production bundle install

# Configure
export SECRET_KEY_BASE="sensitive_secret_key_base" \
  SMTP_ADDRESS=smtp.yourhost.com \
  SMTP_EMAIL_FROM="ciao@yourhost.com" \
  SMTP_EMAIL_TO="you@yourhost.com" \
  SMTP_PORT=587 \
  SMTP_DOMAIN=smtp.yourhost.com \
  SMTP_AUTHENTICATION=plain \
  SMTP_ENABLE_STARTTLS_AUTO=auto \
  SMTP_USERNAME=ciao \
  SMTP_PASSWORD="sensitive_password"

# Run start script - basically this is check SECRET_KEY_BASE, database init/migrate and rails server
RAILS_ENV=production ./start.sh
````

Open localhost:3000 in the webbrowser.

## REST API

**GET /checks.json**

Show collection (array) of all checks

````
curl -X GET -H "Content-type: application/json" /checks.json
````

**GET /checks/<:id>.json**

Show a specific check

````
curl -X GET -H "Content-type: application/json" /checks/<:id>.json
````

**POST /checks.json**

Create a check

````
curl -X POST -H "Content-type: application/json" /checks.json \
  -d '{ "name": "brotandgames.com", "active": true, "url": "https://brotandgames.com", "cron": "* * * *"}'
````

**PATCH/PUT /checks/<:id>.json**

Update a check

````
curl -X PUT -H "Content-type: application/json" /checks/<:id>.json \
  -d '{ "name": "brotandgames.com", "active": false, "url": "https://brotandgames.com", "cron": "* * * *"}'
````

**DELETE /checks/<:id>.json**

Delete a check

````
curl -X DELETE -H "Content-type: application/json" /checks/<:id>.json
````

## Backup & Restore

State is stored in an internal SQLite database located in `db/sqlite/production.sqlite3`.

*NOTE: Prior to version 1.1.0 the database was located in `db/` (missing sqlite subfolder). From 1.1.0 onwards the location is `db/sqlite/` to enable docker to use a volume.*

### Backup

````
docker cp ciao:/app/db/sqlite/production.sqlite3 production.sqlite3.backup
````

### Restore

````
docker cp production.sqlite3.backup ciao:/app/db/sqlite/production.sqlite3
docker restart ciao
````

Visit `/checks/admin` and recreate the background jobs for active checks.

## Upgrade

1. [Backup](#backup) the database
2. Run container with new version
3. [Restore](#restore) the database, restart the container and recreate jobs for active checks

## Deploy

Here you'll find instructions for deploying ciao to different platforms like Kubernetes or Dokku.

Be sure to enable authentication (eg. HTTP Basic auth) and TLS certificates if you serve ciao publicly.

### Kubernetes

Helm Chart is in development.


### Dokku

Create app

````
dokku apps:create ciao
````

Configure

````
dokku config:set --no-restart ciao \
  SECRET_KEY_BASE="sensitive_secret_key_base" \
  SMTP_ADDRESS=smtp.yourhost.com \
  SMTP_EMAIL_FROM="ciao@yourhost.com" \
  SMTP_EMAIL_TO="you@yourhost.com" \
  SMTP_PORT=587 \
  SMTP_DOMAIN=smtp.yourhost.com \
  SMTP_AUTHENTICATION=plain \
  SMTP_ENABLE_STARTTLS_AUTO=auto \
  SMTP_USERNAME=ciao \
  SMTP_PASSWORD="sensitive_password"
````

Deploy ciao using your deployment method eg. [Dockerfile Deployment](http://dokku.viewdocs.io/dokku/deployment/methods/dockerfiles/), [Docker Image Deployment](http://dokku.viewdocs.io/dokku/deployment/methods/images/) etc.

Protect your ciao instance by enabling HTTP Basic auth (using [dokku-http-auth](https://github.com/dokku/dokku-http-auth)) and installing Lets Encrypt certificates via [dokku-letsencrypt](https://github.com/dokku/dokku-letsencrypt).


## Contributing

We encourage you to contribute to ciao in whatever way you like!

## License

ciao is released under the [MIT License](https://opensource.org/licenses/MIT).

## Maintainer

https://github.com/brotandgames
