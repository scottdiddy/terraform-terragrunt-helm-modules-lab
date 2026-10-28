###############################################################################
# SHARED TERRAGRUNT CONFIGURATION (not a Terraform .tf file)
# Each environment includes this file, keeping the backend policy consistent.
# Local state is suitable for this learning lab, NOT shared team production.
###############################################################################
remote_state {
  # This is Terraform's LOCAL state backend (stored on this computer).
  backend = "local"

  # Terragrunt writes a native Terraform `terraform { backend "local" {} }`
  # block into backend.tf in the execution directory / cache.
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  # Parent folder is live/; relative path distinguishes dev from prod.
  # dev => live/.state/dev/platform/terraform.tfstate
  # prod => live/.state/prod/platform/terraform.tfstate
  config = {
    path = "${get_parent_terragrunt_dir()}/.state/${path_relative_to_include()}/terraform.tfstate"
  }
}
