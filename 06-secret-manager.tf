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