resource "google_project_service" "servicenetworking-api" {
  project = var.gcp_project
  service = "servicenetworking.googleapis.com"
}

resource "google_compute_network" "private_network" {
  name = "private-network"
  auto_create_subnetworks = false
}

resource "google_compute_global_address" "private_ip_address" {
  name = "private-ip-address"
  purpose = "VPC_PEERING"
  address_type = "INTERNAL"
  prefix_length = 16
  network = google_compute_network.private_network.id
}

resource "google_service_networking_connection" "default" {
  network = google_compute_network.private_network.id
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}



resource "random_password" "root_password" {
  length = 16
  special = true
}

resource "google_sql_database" "database" {
  name     = "my-database"
  instance = google_sql_database_instance.instance.name
}

# See versions at https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#database_version
resource "google_sql_database_instance" "instance" {
  name             = "my-database-instance"
  region           = var.gcp_region
  database_version = "MYSQL_8_0"

  depends_on = [ google_service_networking_connection.default ]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled = false
      private_network = google_compute_network.private_network.id
    }
  }

  deletion_protection  = "true"
}

resource "google_sql_user" "root_user" {
  instance = google_sql_database_instance.instance.name
  name = "root"
  password = random_password.root_password.result
}

resource "google_compute_network_peering_routes_config" "peering_routes" {
  peering              = google_service_networking_connection.default.peering
  network              = google_compute_network.private_network.name
  import_custom_routes = true
  export_custom_routes = true
}