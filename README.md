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

You can install ciao via a predefined Docker image or using Git and installing the dependencies manually.

Following are two examples using a predefined SECRET_KEY_BASE (will be auto-generated if you omit it) and configuration for SMTP (for sending e-mails).

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
  brotandgames/ciao
````

Open localhost:8090 in your webbrowser.

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
