variable "greeting" {
  description = "Text inserted into the demo app Helm values."
  type        = string
}
variable "replicas" {
  description = "How many nginx pods the demo chart should create."
  type        = number
  default     = 1
}
