resource "google_cloud_run_v2_service" "backend" {
  name = "backend"
  location = var.gcp_region
  
  template {
    service_account = "terraform@cloud-temp-400907.iam.gserviceaccount.com"
    containers {
      image = "gcr.io/cloud-temp-400907/backend"
      ports {
        container_port = 3000
      }
    }
  }
}

resource "google_cloud_run_service_iam_binding" "backend" {
  location = google_cloud_run_v2_service.backend.location
  service = google_cloud_run_v2_service.backend.name
  role = "roles/run.invoker"
  members = [
    "allUsers"
  ]
}

output "backend_url" {
  value = "${google_cloud_run_v2_service.backend.uri}"
}

# Create connection between SQL and cloud run.