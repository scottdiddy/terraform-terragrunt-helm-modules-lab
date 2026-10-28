###############################################################################
# ROOT TERRAFORM MODULE (selected by Terragrunt's terraform.source)
# HERE IS THE MODULE KEYWORD YOU WANTED TO LEARN.
# `module "argocd"` and `module "demo_app"` CALL two separate directories.
# Each child module defines its OWN helm_release RESOURCE.
# Provider config is NOT duplicated: both inherit provider "helm" from
# providers.tf in THIS root module.
# Both children are in ONE Terraform state for this environment.
###############################################################################
module "argocd" {
  source = "../argocd" # Relative to THIS Terraform module's directory.

  # Left side: names declared in modules/argocd/variables.tf
  # Right side: ROOT module inputs supplied by Terragrunt.
  domain           = var.argocd_domain
  server_replicas  = var.argocd_server_replicas
  chart_version    = var.argocd_chart_version

  # Explicit for learning: could omit this providers map because the
  # default (unaliased) Helm provider is inherited automatically.
  providers = {
    helm = helm
  }
}

module "demo_app" {
  source = "../demo-app"

  greeting = var.greeting
  replicas = var.demo_replicas

  # Both child modules share the SAME configured Helm provider instance.
  providers = {
    helm = helm
  }
}

# This root has TWO child module calls. No extra helm_release resources here.
# You can remove the explicit providers maps above and inheritance still works.
