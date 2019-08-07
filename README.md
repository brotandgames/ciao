# ciao

[![Latest release](https://img.shields.io/github/release/brotandgames/ciao.svg)](https://github.com/brotandgames/ciao/releases/latest)
[![Docker pulls](https://img.shields.io/docker/pulls/brotandgames/ciao.svg)](https://store.docker.com/community/images/brotandgames/ciao)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/brotandgames/ciao/master/LICENSE)
[![Build Status](https://travis-ci.org/brotandgames/ciao.svg?branch=master)](https://travis-ci.org/brotandgames/ciao)
[![Gitter chat](https://badges.gitter.im/brotandgames/ciao.png)](https://gitter.im/brotandgames/ciao)
[![Website link](https://brotandgames.com/assets/ciao-link-website.svg)](https://brotandgames.com/ciao/)

**[ciao](https://www.brotandgames.com/ciao/)** checks HTTP(S) URL endpoints for a HTTP status code (or errors on the lower TCP stack) and sends a notification on status change via E-Mail or Webhooks.

It uses Cron syntax to schedule the checks and comes along with a Web UI and a RESTfull JSON API.

![ciao Checks overview](https://brotandgames.com/assets/ciao-checks.png "ciao Checks overview")
*You can find more screenshots on the [Homepage](https://www.brotandgames.com/ciao/).*

**ciao** (/tʃaʊ/) - **c**heck **i**n **a**nd **o**ut - borrowed from Italian *ciao* for greeting someone.

*Motivation:* create an open source web application for checking URL statuses with an UI and a REST API which is easy to install and maintain (no external dependencies like Databases, Caches etc.) in public and private environments.

Follow [@brotandgames](https://www.twitter.com/brotandgames) on Twitter to get the latest News like Releases. Use [#ciaohttp](https://twitter.com/hashtag/ciaohttp) Hashtag for ciao related stuff.

## Quickstart

````
docker run --name ciao -p 8090:3000 brotandgames/ciao
````

Open localhost:8090 in your webbrowser.

## Features

* Check HTTP/S endpoints in an interval
* Use Cron syntax like `* * * * *` (every minute), `*/15 * * * *` (every 15 minutes), `@hourly` or `@daily` etc.
* Web UI
* [RESTfull JSON API](#rest-api)
* Get a notification on status change via [E-Mail](smtp_configuration.md) eg. Gmail, Sendgrid, MailChimp or [Webhooks](webhook_configuration.md) eg. RocketChat, Slack etc. (optional)
* Configuration via ENVIRONMENT variables (suitable for most runtimes)
* Expose Prometheus Metrics endpoint `/metrics` with information to digest by tools like Grafana (optional)
* Protect with HTTP Basic auth on application basis (optional, only recommended in combination with TLS)
* Instructions for [installing](#install)/[deploying](#deploy) in/to different Platforms
* [Docker Image](#via-docker-image)
* [Helm Chart](#via-helm)


## Configuration

ciao is configured via ENVIRONMENT variables following the [12-factor app methodology](https://12factor.net/config).

- `SECRET_KEY_BASE` will be auto-generated if you omit it
- Time zone is configurable per `TIME_ZONE` variable (default: `UTC`) eg. `TIME_ZONE="Vienna"` - you can find all possible values by executing `docker run --rm brotandgames/ciao rake time:zones` (since version 1.2.0)
- Check [SMTP Configuration](smtp_configuration.md) for all possible configuration variables, notes and example configurations for Gmail, Sendgrid etc.
- Check [Webhook Configuration](webhook_configuration.md) for instructions how to send (webhook) notifications to RocketChat, Slack etc. (since version 1.4.0)
- You can enable HTTP Basic auth for ciao by defining `BASIC_AUTH_USERNAME` and `BASIC_AUTH_PASSWORD` eg. `BASIC_AUTH_USERNAME="ciao-admin"` and `BASIC_AUTH_PASSWORD="sensitive_password"` (since version 1.3.0)
- You can enable a Prometheus Metrics endpoint served under `/metrics` by setting `PROMETHEUS_ENABLED=true` - furthermore you can enable HTTP Basic auth for this endpoint by defining `PROMETHEUS_BASIC_AUTH_USERNAME="ciao-metrics"` and `PROMETHEUS_BASIC_AUTH_PASSWORD="sensitive_password"` (since version 1.5.0)

## Install

You can install ciao via the official Docker image `brotandgames/ciao` or using Git and installing the dependencies manually.

By mounting a Docker volume you can avoid loosing data on restart or upgrade.

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
*Prior to version 1.2.0: visit `/checks/admin` and recreate the background jobs for active checks.*


## Upgrade

1. [Backup](#backup) the database
2. Run container with new version
3. [Restore](#restore) the database

## Deploy

Here you'll find instructions for deploying ciao to different platforms like Kubernetes or Dokku.

By mounting a Docker or Kubernetes volume you can avoid loosing data on restart or upgrade.

IMPORTANT: Be sure to enable authentication (eg. HTTP Basic auth) and TLS certificates if you serve ciao publicly.

### Kubernetes

#### Via Helm

Install ciao via Helm Chart from the official repository.

Source is located in `./chart` and released to https://releases.brotandgames.com/helm-charts.

1. Use `helm repo add` command to add the Helm chart repository that contains charts to install ciao.

````
helm repo add brotandgames https://releases.brotandgames.com/helm-charts

# helm search brotandgames
# should output something like this
# NAME              CHART VERSION APP VERSION DESCRIPTION
# brotandgames/ciao 0.1.0         latest      Ciao - HTTP checks & tests (private & public) monitoring
````

2. Install ciao via `helm upgrade --install`

Quickstart (without configuring)

````
helm upgrade --install --namespace your-namespace your-release-name brotandgames/ciao
````

With [configuration](#configuration)

````
helm upgrade --install --namespace your-namespace your-release-name brotandgames/ciao \
  --set env.SECRET_KEY_BASE="sensitive_secret_key_base" \
  --set env.SMTP_ADDRESS=smtp.yourhost.com \
  --set env.SMTP_EMAIL_FROM="ciao@yourhost.com" \
  --set env.SMTP_EMAIL_TO="you@yourhost.com" \
  --set env.SMTP_PORT=587 \
  --set env.SMTP_DOMAIN=smtp.yourhost.com \
  --set env.SMTP_AUTHENTICATION=plain \
  --set env.SMTP_ENABLE_STARTTLS_AUTO=auto \
  --set env.SMTP_USERNAME=ciao \
  --set env.SMTP_PASSWORD="sensitive_password"
````

#### Via kubectl

The following code snippent will create a Kubernetes

* Namespace `monitoring`,
* Secret `ciao`,
* Deployment `ciao` and
* Service `ciao`.

`kubectl apply -f k8s.yaml`

````
# k8s.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
---
apiVersion: v1
kind: Secret
metadata:
  name: ciao
  namespace: monitoring
data:
  # all values should be base64 encoded
  # so some_secret would be c29tZV9zZWNyZXQ=
  SECRET_KEY_BASE: some_secret
  SMTP_ADDRESS: smtp_address
  SMTP_EMAIL_FROM: noreply@somedomain.com
  SMTP_EMAIL_TO: monitoring@somedomain.com
  SMTP_PORT: 465
  SMTP_DOMAIN: mail.somedomain.com
  SMTP_AUTHENTICATION: plain
  SMTP_ENABLE_STARTTLS_AUTO: auto
  SMTP_USERNAME: smtp_some_username
  SMTP_PASSWORD: smtp_some_password
  SMTP_SSL: true
  BASIC_AUTH_USERNAME: auth_some_username
  BASIC_AUTH_PASSWORD: auth_some_password
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: ciao
  namespace: monitoring
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: ciao
    spec:
      containers:
      - image: brotandgames/ciao:latest
        imagePullPolicy: IfNotPresent
        name: ciao
        volumeMounts: # Emit if you do not have persistent volumes
        - mountPath: /app/db/sqlite/
          name: persistent-volume
          subPath: ciao
        ports:
        - containerPort: 3000
        resources:
          requests:
            memory: 256Mi
            cpu: 200m
          limits:
            memory: 512Mi
            cpu: 400m
        envFrom:
        - secretRef:
            name: ciao
---
apiVersion: v1
kind: Service
metadata:
  name: ciao
  namespace: monitoring
spec:
  ports:
    - port: 80
      targetPort: 3000
      protocol: TCP
  type: ClusterIP
  selector:
    app: ciao
````

### Dokku

1. Create app

````
dokku apps:create ciao
````

2. Configure

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

3. Deploy ciao using your deployment method eg. [Dockerfile Deployment](http://dokku.viewdocs.io/dokku/deployment/methods/dockerfiles/), [Docker Image Deployment](http://dokku.viewdocs.io/dokku/deployment/methods/images/) etc.

4. Protect your ciao instance by enabling HTTP Basic auth (using [dokku-http-auth](https://github.com/dokku/dokku-http-auth)) and installing Lets Encrypt certificates via [dokku-letsencrypt](https://github.com/dokku/dokku-letsencrypt).


## Contributing

We encourage you to contribute to ciao in whatever way you like!

## Versioning

[Semantic Versioning 2.x](https://semver.org/)

In a nutshell:

> Given a version number MAJOR.MINOR.PATCH, increment the:
>
> 1. MAJOR version when you make incompatible API changes,
> 2. MINOR version when you add functionality in a backwards-compatible manner, and
> 3. PATCH version when you make backwards-compatible bug fixes.
>
> Additional labels for pre-release and build metadata are available as extensions to the MAJOR.MINOR.PATCH format.

## License

ciao is released under the [MIT License](https://opensource.org/licenses/MIT).

## Guestbook

Why not reinvent the [guestbook](guestbook.md)?

## Maintainer

https://github.com/brotandgames
