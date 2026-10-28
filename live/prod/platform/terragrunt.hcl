###############################################################################
# PROD-LIKE LEARNING ENVIRONMENT (a separate local Kind cluster, NOT real prod)
# Same root module and child modules; different inputs and separate state.
###############################################################################
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../..//modules/platform"
}

inputs = {
  kube_context           = "kind-helm-lab-prod"
  argocd_domain          = "argocd-prod.localtest.me"
  argocd_server_replicas = 1
  argocd_chart_version   = "10.10.3"
  greeting               = "Hello from PROD-LIKE (Terraform child module)!"
  demo_replicas          = 2
}
