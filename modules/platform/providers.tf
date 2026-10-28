###############################################################################
# SINGLE HELM PROVIDER CONFIGURATION — THE MOST IMPORTANT DESIGN CHOICE
# Configure the Kubernetes target ONCE in the ROOT module.
# Child modules use this configuration by default (provider inheritance).
# We do NOT put provider "helm" inside the ArgoCD or demo-app child modules.
###############################################################################
provider "helm" {
  kubernetes = {
    config_path    = "~/.kube/config"
    config_context = var.kube_context
  }
}
