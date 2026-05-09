resource "kubernetes_network_policy" "default_deny_api" {
  metadata {
    name      = "default-deny"
    namespace = "api"
  }

  spec {
    pod_selector {}

    policy_types = ["Ingress", "Egress"]
  }
}
