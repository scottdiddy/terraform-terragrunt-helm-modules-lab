###############################################################################
# DEV TERRAGRUNT UNIT
# One Terragrunt execution uses ONE platform ROOT module which calls TWO
# child modules with actual Terraform `module` blocks.
###############################################################################
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  # The `//` is INTENTIONAL: copy the whole repository package to the cache,
  # then enter modules/platform. This preserves sibling modules/argocd and
  # modules/demo-app when platform/main.tf uses ../argocd and ../demo-app.
  # From live/dev/platform, ../../.. points to the repository root.
  source = "../../..//modules/platform"
}

inputs = {
  kube_context         = "kind-helm-lab-dev"
  argocd_domain        = "argocd-dev.localtest.me"
  argocd_server_replicas = 1
  # Check your installed chart repo if an older version is needed.
  argocd_chart_version = "10.10.3"
  greeting             = "Hello from DEV (Terraform child module)!"
  demo_replicas        = 1
}
