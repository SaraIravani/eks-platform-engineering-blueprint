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
resource "kubernetes_deployment" "batch_test" {
  metadata {
    name      = "batch-test"
    namespace = kubernetes_namespace.this["batch"].metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "batch-test"
      }
    }

    template {
      metadata {
        labels = {
          app      = "batch-test"
          workload = "batch"
        }
      }

      spec {
        priority_class_name = "batch-low-priority"

        node_selector = {
          workload = "batch"
        }

        toleration {
          key      = "workload"
          operator = "Equal"
          value    = "batch"
          effect   = "NoSchedule"
        }

        container {
          name    = "busybox"
          image   = "busybox:latest"
          command = ["sh", "-c", "sleep 3600"]
        }
      }
    }
  }

  depends_on = [kubernetes_priority_class.batch_low]
}
