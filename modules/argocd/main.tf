###############################################################################
# CHILD MODULE 1: ARGOCD
# `resource` declares a MANAGED Helm release; `module` (in parent) calls us.
# No provider "helm" block here: supplied by root module providers.tf.
###############################################################################
resource "helm_release" "argocd" {
  name             = "argocd"               # Helm release name
  namespace        = "argocd"               # Install in argocd namespace
  create_namespace = true                   # Create namespace if necessary
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version      # Direct helm_release attribute
  wait             = true
  timeout          = 900

  # values expects a LIST of YAML strings. templatefile() returns one YAML
  # string after replacing ${domain} and ${server_replicas} placeholders.
  values = [
    templatefile("${path.module}/argocd-values.yaml.tftpl", {
      domain          = var.domain
      server_replicas = var.server_replicas
    })
  ]
}
