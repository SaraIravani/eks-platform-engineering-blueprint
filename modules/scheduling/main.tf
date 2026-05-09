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
resource "kubernetes_deployment" "api_test" {
  metadata {
    name      = "api-test"
    namespace = kubernetes_namespace.this["api"].metadata[0].name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "api-test"
      }
    }

    template {
      metadata {
        labels = {
          app      = "api-test"
          workload = "api"
        }
      }

      spec {
        priority_class_name = "api-high-priority"

        node_selector = {
          workload = "api"
        }

        container {
          name  = "nginx"
          image = "nginx:latest"

          port {
            container_port = 80
          }
        }
      }
    }
  }

  depends_on = [kubernetes_priority_class.api_high]
}
