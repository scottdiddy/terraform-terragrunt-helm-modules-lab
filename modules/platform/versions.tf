###############################################################################
# ROOT MODULE PROVIDER REQUIREMENT
# This says WHICH plugin Terraform needs, not how it authenticates.
# Terraform init resolves the provider for the entire root module dependency
# graph; the child's own required_providers declarations do NOT imply a
# second independent installation of the plugin.
###############################################################################
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}
