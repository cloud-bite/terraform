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

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      authorized_networks {
        value = "0.0.0.0/0" // Allow all connections, but should be restricted to the VPC/network and only allow cloud run once that is provisioned.
      }
    }
  }

  deletion_protection  = "true"
}

resource "google_sql_user" "root_user" {
  instance = google_sql_database_instance.instance.name
  name = "root"
  password = random_password.root_password.result
}