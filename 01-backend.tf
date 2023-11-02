resource "google_cloud_run_v2_service" "backend" {
  name = "backend"
  location = "europe-north1"
  template {
    containers {
      image = "gcr.io/cloud-temp-400907/backend"
      ports {
        container_port = 3000
      }
    }
  }
}

output "backend_url" {
  value = "${google_cloud_run_v2_service.backend.uri}"
}

