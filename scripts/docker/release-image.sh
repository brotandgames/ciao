#!/usr/bin/env bash

docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
docker build -t brotandgames/ciao:$TRAVIS_TAG .
docker tag brotandgames/ciao:$TRAVIS_TAG brotandgames/ciao:latest
docker push brotandgames/ciao:$TRAVIS_TAG
docker push brotandgames/ciao:latest
