resource "google_secret_manager_secret" "db_host" {
  secret_id = "DB_HOST"

  labels = {
    label = "db"
  }

  replication {
    user_managed {
      replicas {
        location = var.gcp_region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "db_host" {
  secret = google_secret_manager_secret.db_host.id

  secret_data = google_sql_database_instance.instance.private_ip_address
}

resource "google_secret_manager_secret" "db_name" {
  secret_id = "DB_NAME"

  labels = {
    label = "db"
  }

  replication {
    user_managed {
      replicas {
        location = var.gcp_region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "db_name" {
  secret = google_secret_manager_secret.db_name.id

  secret_data = google_sql_database.database.name
}

resource "google_secret_manager_secret" "db_user" {
  secret_id = "DB_USER"

  labels = {
    label = "db"
  }

  replication {
    user_managed {
      replicas {
        location = var.gcp_region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "db_user" {
  secret = google_secret_manager_secret.db_user.id

  secret_data = google_sql_user.root_user.name
}

resource "google_secret_manager_secret" "db_pass" {
  secret_id = "DB_PASS"

  labels = {
    label = "db"
  }

  replication {
    user_managed {
      replicas {
        location = var.gcp_region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "db_pass" {
  secret = google_secret_manager_secret.db_pass.id

  secret_data = google_sql_user.root_user.password
}