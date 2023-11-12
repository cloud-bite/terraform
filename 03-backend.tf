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
      
      # These values are here, before they are set in secret manager.
      env {
        name = "DB_HOST"
        value = google_sql_database_instance.instance.public_ip_address # This is currently using the public IP; but should be transferred to the private when using the isolated VPC/network.
      }
      env {
        name = "DB_NAME"
        value = google_sql_database.database.name
      }
      env {
        name = "DB_USER"
        value = "root"
      }
      env {
        name = "DB_PASS"
        value = random_password.root_password.result
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