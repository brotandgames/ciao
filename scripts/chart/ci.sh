#!/usr/bin/env bash

set -e

self=${0##*/}
dependencies=helm,mc

echo "== $self"

# Check dependencies
for d in $(echo $dependencies | tr "," "\n"); do
  command -v $d >/dev/null 2>&1 || { echo >&2 "== $self requires $d but it's not installed."; exit 1; }
done

CHART_NAME=ciao
CHART_HELM_REPO=https://releases.brotandgames.com/helm-charts

cd $(dirname $0)/..

rm -rf /tmp/chart
mkdir -p /tmp/chart/
cp -Rf ../chart /tmp/chart/$CHART_NAME

echo "== $self Chart validate"
helm lint /tmp/chart/$CHART_NAME

echo "== $self Chart package"
helm package -d /tmp/chart /tmp/chart/$CHART_NAME

rm -rf /tmp/chart/$CHART_NAME

echo "== $self Get current index.yaml from $CHART_HELM_REPO"
curl -f -H 'Cache-Control: max-age=0,no-cache' "$CHART_HELM_REPO/index.yaml" -o /tmp/chart/repo_index.yaml || true

if [ -f /tmp/chart/repo_index.yaml ]; then
  echo "== $self Update index.yaml"
  helm repo index --merge /tmp/chart/repo_index.yaml /tmp/chart
  rm /tmp/chart/repo_index.yaml
else
  echo "== $self Create index.yaml"
  helm repo index /tmp/chart
fi

echo "== $self Upload index.yaml and *.tgz to $CHART_HELM_REPO"
mc cp -r /tmp/chart/ brotandgames/helm-charts/
