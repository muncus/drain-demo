
output "cluster-a-endpoint" {
  description = "the kubernetes endpoint for Cluster A"
  value       = module.cluster-a.endpoint
  sensitive   = true
}
output "cluster-b-endpoint" {
  description = "the kubernetes endpoint for Cluster B"
  value       = module.cluster-b.endpoint
  sensitive   = true
}