# resource "google_compute_url_map" "global-lb" {
#     name = "global frontend urlmap"
#     description = "global frontend lb."
#     default_service = google_compute_backend_service.whereami-global.id
# }

# resource "google_compute_backend_service" "whereami-global" {
#     name = "whereami-global"
#     port_name = "http"
#     protocol = "HTTP"
#     backend {
#         group = 
#     }
# }
data "kubernetes_service" "lb-backend-A" {
  provider = kubernetes.cluster-A
  metadata {
    name = "whereami"
  }
}
data "kubernetes_service" "lb-backend-B" {
  provider = kubernetes.cluster-B
  metadata {
    name = "whereami"
  }
}
locals {
  svc_port = data.kubernetes_service.lb-backend-A.spec.0.port.0.port
  // NEG info for backend A
  // this info is encoded in the annotations on the kubernetes object, after the NEG is created.
  // so we use a 'data' object to retrieve current annotations, rather than 'resource'.
  svc_a_neg_notes = jsondecode(data.kubernetes_service.lb-backend-A.metadata[0].annotations["cloud.google.com/neg-status"])
  svc_a_neg_name  = local.svc_a_neg_notes["network_endpoint_groups"][local.svc_port]
  svc_a_neg_zone  = local.svc_a_neg_notes["zones"][0]
  // NEG info for backend B
  svc_b_neg_notes = jsondecode(data.kubernetes_service.lb-backend-B.metadata[0].annotations["cloud.google.com/neg-status"])
  svc_b_neg_name  = local.svc_b_neg_notes["network_endpoint_groups"][local.svc_port]
  svc_b_neg_zone  = local.svc_b_neg_notes["zones"][0]
}

data "google_compute_network_endpoint_group" "neg-A" {
  name = local.svc_a_neg_name
  zone = local.svc_a_neg_zone
}
data "google_compute_network_endpoint_group" "neg-B" {
  name = local.svc_b_neg_name
  zone = local.svc_b_neg_zone
}

// Health check, using the serving port on the kubernetes service object.
resource "google_compute_health_check" "default" {
  name = "health-check"
  http_health_check {
    port = 8080
  }
}

resource "google_compute_backend_service" "default" {
  name                  = "terraform-bs"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  protocol              = "HTTP"
  health_checks         = [google_compute_health_check.default.id]
  // for demonstration, use a random backend.
  locality_lb_policy = "RANDOM"
  //NEGS go here.
  backend {
    group          = data.google_compute_network_endpoint_group.neg-A.self_link
    balancing_mode = "RATE"
    // zero is not a valid max_rate. must remove whole block.
    max_rate_per_endpoint = 100
  }
  backend {
    group                 = data.google_compute_network_endpoint_group.neg-B.self_link
    balancing_mode        = "RATE"
    max_rate_per_endpoint = 100
  }
}

resource "google_compute_url_map" "default" {
  name            = "terraform-lb"
  default_service = google_compute_backend_service.default.id
}

resource "google_compute_target_http_proxy" "default" {
  name    = "tfproxy"
  url_map = google_compute_url_map.default.id
}

resource "google_compute_global_forwarding_rule" "default" {
  name                  = "lb-tf"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
}

output "frontend" {
  value = google_compute_global_forwarding_rule.default.ip_address
}
