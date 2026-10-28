# Child modules still DECLARE their plugin requirement so Terraform knows
# which provider `helm_release` belongs to. This is NOT another provider
# CONFIGURATION, another Helm installation, or a second plugin download.
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}
