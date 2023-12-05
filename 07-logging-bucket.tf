# A gcs bucket to store logs in
resource "google_storage_bucket" "gcs-logging-bucket" {
  name     = "project-logging-bucket"
  location = "EU"
}
