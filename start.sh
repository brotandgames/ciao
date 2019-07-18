#!/bin/sh

set -euo pipefail

self="$(basename "$0")"

if [ -z "${SECRET_KEY_BASE:-}" ]; then
  echo "== $self WARNING: SECRET_KEY_BASE not set"
  echo "== $self It will be set to a random value using \`rake secret\`"
  export SECRET_KEY_BASE="$(rake secret)"
fi

rake db:migrate

exec rails server -b 0.0.0.0 -p 3000
