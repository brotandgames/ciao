. ./ci.sh

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
rm -rf /tmp/chart/$CHART_NAME
mc cp -r /tmp/chart/ brotandgames/helm-charts/
