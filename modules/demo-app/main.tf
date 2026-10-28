###############################################################################
# CHILD MODULE 2: DEMO APP
# Unlike ArgoCD, this release uses our OWN LOCAL HELM CHART in ./chart.
# That lets you inspect Chart.yaml, values.yaml, and templates/*.yaml.
# One Helm provider configuration is inherited from the parent.
###############################################################################
resource "helm_release" "demo" {
  name             = "hello-helm"
  namespace        = "hello"
  create_namespace = true
  chart            = "${path.module}/chart" # Local chart; no repository needed
  wait             = true
  timeout          = 300

  # yamlencode takes a Terraform object and converts it to YAML text.
  # Compare this with templatefile() in the ArgoCD child module:
  # Both approaches pass Helm chart settings via the values attribute.
  values = [
    yamlencode({
      replicaCount = var.replicas
      greeting     = var.greeting
    })
  ]
}
