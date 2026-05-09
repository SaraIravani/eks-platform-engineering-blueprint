output "default_storage_class" {
  description = "Default Kubernetes StorageClass"
  value       = kubernetes_storage_class.gp3.metadata[0].name
}

output "high_performance_storage_class" {
  description = "High performance Kubernetes StorageClass"
  value       = kubernetes_storage_class.io2.metadata[0].name
}
