#!/usr/bin/env bash
set -euo pipefail
CONTEXT=kind-helm-lab-dev
kubectl get pods -n argocd --context "$CONTEXT"
kubectl get pods -n hello --context "$CONTEXT"
helm list -n argocd --kube-context "$CONTEXT"
helm list -n hello --kube-context "$CONTEXT"
helm get values hello-helm -n hello --kube-context "$CONTEXT"
# Run in another terminal: kubectl --context "$CONTEXT" -n hello port-forward svc/hello-helm 8081:80
