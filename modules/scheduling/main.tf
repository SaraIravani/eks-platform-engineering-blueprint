resource "kubernetes_namespace" "this" {
  for_each = toset(var.namespaces)

  metadata {
    name = each.value

    labels = {
      "platform.io/isolation" = each.value
    }
  }
}
resource "kubernetes_priority_class" "api_high" {
  metadata {
    name = "api-high-priority"
  }

  value          = 100000
  global_default = false
  description    = "High priority class for SLA-sensitive API workloads"
}

resource "kubernetes_priority_class" "batch_low" {
  metadata {
    name = "batch-low-priority"
  }

  value          = 1000
  global_default = false
  description    = "Low priority class for non-critical batch workloads"
}
