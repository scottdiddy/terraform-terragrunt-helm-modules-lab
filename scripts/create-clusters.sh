#!/usr/bin/env bash
set -euo pipefail
# Requires Docker and kind. Create two independent local Kubernetes clusters.
kind create cluster --name helm-lab-dev
kind create cluster --name helm-lab-prod
kubectl config get-contexts
