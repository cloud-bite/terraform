resource "google_project_service" "vpcaccess-api" {
  project = var.gcp_project
  service = "vpcaccess.googleapis.com"
}

resource "google_vpc_access_connector" "connector" {
  name = "vpc-connector"
  ip_cidr_range = "10.10.11.0/28"
  network = google_compute_network.private_network.name
}

resource "google_service_account" "backend_service_account" {
  account_id = "backend-service-account-new"
  display_name = "Backend Service Account"
}

resource "google_cloud_run_v2_service" "backend" {
  name = "backend"
  location = var.gcp_region
  
  template {
    service_account = google_service_account.backend_service_account.email
    containers {
      image = "gcr.io/cloud-temp-400907/backend"
      ports {
        container_port = 3000
      }

      env {
        name = "DB_HOST_SECRET"
        value = google_secret_manager_secret_version.db_host.id
      }
      env {
        name = "DB_NAME_SECRET"
        value = google_secret_manager_secret_version.db_name.id
      }
      env {
        name = "DB_USER_SECRET"
        value = google_secret_manager_secret_version.db_user.id
      }
      env {
        name = "DB_PASS_SECRET"
        value = google_secret_manager_secret_version.db_pass.id
      }
    }

    
    vpc_access {
      connector = google_vpc_access_connector.connector.id
      egress = "ALL_TRAFFIC"
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

resource "google_project_iam_binding" "backend_secret_accessor" {
  project = var.gcp_project
  role = "roles/secretmanager.secretAccessor"
  members = [
    "serviceAccount:${google_service_account.backend_service_account.email}"
  ]
}
resource "google_logging_project_sink" "backend-instance-sink" {
  name        = "backend-logging-sink"
  description = "This is the bucket containing the sink for logging the backend bucket"
  destination = "storage.googleapis.com/${google_storage_bucket.gcs-logging-bucket.name}"
  filter      = "resource.type = gce_instance AND resource.labels.instance_id = \"${google_cloud_run_v2_service.backend.id}\""

  unique_writer_identity = true
}

resource "google_project_iam_binding" "gcs-bucket-backend-writer" {
  project = var.gcp_project
  role    = "roles/storage.objectCreator"

  members = [
    google_logging_project_sink.backend-instance-sink.writer_identity,
  ]
}
