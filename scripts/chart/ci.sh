#!/usr/bin/env bash

set -e

self=${0##*/}
ci_dependencies=helm

echo "== $self"

# Check dependencies
for d in $(echo $ci_dependencies | tr "," "\n"); do
  command -v $d >/dev/null 2>&1 || { echo >&2 "== $self requires $d but it's not installed."; exit 1; }
done

CHART_NAME=ciao

cd $(dirname $0)/..

rm -rf /tmp/chart
mkdir -p /tmp/chart/
cp -Rf ../chart /tmp/chart/$CHART_NAME

echo "== $self Chart validate"
helm lint /tmp/chart/$CHART_NAME

echo "== $self Helm init"
echo "== $self Check: https://github.com/helm/helm/issues/1732"
helm init --client-only

echo "== $self Chart package"
helm package -d /tmp/chart /tmp/chart/$CHART_NAME
