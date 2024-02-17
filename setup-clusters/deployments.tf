resource "kubernetes_deployment" "A-whereami" {
  provider   = kubernetes.cluster-A
  depends_on = [module.cluster-a]
  metadata {
    name = "whereami"
  }
  spec {
    // Allow extra time for autopilot clusters to add nodes
    progress_deadline_seconds = 1800
    replicas                  = 3
    selector {
      match_labels = {
        app = "whereami"
      }
    }
    template {
      metadata {
        labels = {
          app = "whereami"
        }
      }
      spec {
        container {
          image = "us-docker.pkg.dev/google-samples/containers/gke/whereami:v1.2.22"
          name  = "whereami"
          port {
            name           = "http"
            container_port = 8080
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "A-whereami" {
  provider   = kubernetes.cluster-A
  depends_on = [module.cluster-a]
  metadata {
    name = "whereami"
  }
  spec {
    selector = {
      app = "whereami"
    }
    type             = "LoadBalancer"
    session_affinity = "ClientIP"
    port {
      name        = "http"
      port        = 8080
      target_port = "http"
    }
  }

}

resource "kubernetes_ingress_v1" "A-whereami" {
  provider   = kubernetes.cluster-A
  depends_on = [module.cluster-a]
  metadata {
    name = "whereami"
  }
  spec {
    default_backend {
      service {
        name = "whereami"
        port {
          name = "http"
        }
      }
    }
  }
}

resource "kubernetes_deployment" "B-whereami" {
  provider   = kubernetes.cluster-B
  depends_on = [module.cluster-b]
  metadata {
    name = "whereami"
  }
  spec {
    // Allow extra time for autopilot clusters to add nodes
    progress_deadline_seconds = 1800
    replicas                  = 3
    selector {
      match_labels = {
        app = "whereami"
      }
    }
    template {
      metadata {
        labels = {
          app = "whereami"
        }
      }
      spec {
        container {
          image = "us-docker.pkg.dev/google-samples/containers/gke/whereami:v1.2.22"
          name  = "whereami"
          port {
            name           = "http"
            container_port = 8080
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "B-whereami" {
  provider   = kubernetes.cluster-B
  depends_on = [module.cluster-b]
  metadata {
    name = "whereami"
  }
  spec {
    selector = {
      app = "whereami"
    }
    type             = "LoadBalancer"
    session_affinity = "ClientIP"
    port {
      name        = "http"
      port        = 8080
      target_port = "http"
    }
  }

}

resource "kubernetes_ingress_v1" "B-whereami" {
  provider   = kubernetes.cluster-B
  depends_on = [module.cluster-b]
  metadata {
    name = "whereami"
  }
  spec {
    default_backend {
      service {
        name = "whereami"
        port {
          name = "http"
        }
      }
    }
  }
}