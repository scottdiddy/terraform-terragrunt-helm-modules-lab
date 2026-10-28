output "release_name" {
  value = helm_release.demo.name
}
output "namespace" {
  value = helm_release.demo.namespace
}
