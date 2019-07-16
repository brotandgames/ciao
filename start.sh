#!/usr/bin/env bash

set -e

rake db:migrate

exec rails server -b 0.0.0.0 -p 3000