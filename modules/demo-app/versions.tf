# Same provider SOURCE REQUIREMENT, no duplicated provider configuration.
# Provider requirement declarations in multiple modules are normal.
terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0"
    }
  }
}
