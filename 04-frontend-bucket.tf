resource "google_storage_bucket" "website" {
  name = "cb-website"
  location = "EU"

  website {
    main_page_suffix = "index.html"
    not_found_page = "index.html"
  }
}

resource "google_storage_default_object_access_control" "website_read" {
  bucket = google_storage_bucket.website.name
  role = "READER"
  entity = "allUsers"
}

resource "google_logging_project_sink" "website-instance-sink" {
  name        = "website-logging-sink"
  description = "This is the bucket containing the sink for logging the frontend bucket"
  destination = "storage.googleapis.com/${google_storage_bucket.gcs-logging-bucket.name}"
  filter      = "resource.type = gce_instance AND resource.labels.instance_id = \"${google_compute_backend_bucket.website.bucket_name}\""

  unique_writer_identity = true
}

resource "google_project_iam_binding" "gcs-bucket-website-writer" {
  project = var.gcp_project
  role    = "roles/storage.objectCreator"

  members = [
    google_logging_project_sink.website-instance-sink.writer_identity,
  ]
}
