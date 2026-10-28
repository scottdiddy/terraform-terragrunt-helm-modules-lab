# Outputs bubble values up from the children; they don't create resources.
output "argocd_release" {
  description = "Helm release name returned by the ArgoCD child module."
  value       = module.argocd.release_name
}

output "demo_release" {
  description = "Helm release name returned by the demo child module."
  value       = module.demo_app.release_name
}

output "demo_namespace" {
  value = module.demo_app.namespace
}
