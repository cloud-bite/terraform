resource "google_project_service" "vpcaccess-api" {
  project = var.gcp_project
  service = "vpcaccess.googleapis.com"
}

resource "google_vpc_access_connector" "connector" {
  name = "vpc-connector"
  ip_cidr_range = "10.10.11.0/28"
  network = google_compute_network.private_network.name
}

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

      env {
        name = "DB_HOST"
        value = google_sql_database_instance.instance.private_ip_address # This is currently using the public IP; but should be transferred to the private when using the isolated VPC/network.
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

# Create connection between SQL and cloud run.