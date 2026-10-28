#!/usr/bin/env bash
set -euo pipefail
# Static validation / optional chart lint. Terraform init needs internet.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if command -v helm >/dev/null; then
  helm lint "$ROOT/modules/demo-app/chart"
  helm template hello-helm "$ROOT/modules/demo-app/chart" --set greeting='Helm template test'
else
  echo 'helm not found: skipping Helm checks'
fi
if command -v terraform >/dev/null; then
  terraform fmt -check -recursive "$ROOT/modules"
else
  echo 'terraform not found: skipping terraform fmt'
fi
