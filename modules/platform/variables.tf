# These inputs belong to the ROOT module and come from Terragrunt's inputs.
variable "kube_context" {
  description = "Named context in ~/.kube/config; chooses dev vs prod Kind cluster."
  type        = string
}

variable "argocd_domain" {
  description = "Domain setting passed down to the ArgoCD child module."
  type        = string
}

variable "argocd_server_replicas" {
  description = "Desired number of ArgoCD API server pods."
  type        = number
  default     = 1
}

variable "argocd_chart_version" {
  description = "Chart version, NOT Terraform Helm provider version."
  type        = string
}

variable "greeting" {
  description = "Text shown by the locally charted demo nginx app."
  type        = string
}

variable "demo_replicas" {
  description = "Number of demo nginx pods."
  type        = number
  default     = 1
}
