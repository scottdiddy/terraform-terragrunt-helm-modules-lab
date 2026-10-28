# These belong to the CHILD module, supplied by module "argocd" in platform.
variable "domain" {
  type = string
}
variable "server_replicas" {
  type    = number
  default = 1
}
variable "chart_version" {
  type = string
}
