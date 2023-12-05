resource "google_compute_global_address" "website" {
  name = "website-lb-ip"
}

resource "google_compute_backend_bucket" "website" {
  name = "website-backend"
  description = "Contains files needed by the website"
  bucket_name = google_storage_bucket.website.name
  enable_cdn = true
}

resource "google_compute_url_map" "website" {
  name = "website-url-map"
  default_service = google_compute_backend_bucket.website.id
}

resource "google_compute_target_http_proxy" "website" {
  name = "website-target-proxy"
  url_map = google_compute_url_map.website.id
}

resource "google_compute_global_forwarding_rule" "default" {
  name = "website-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address = google_compute_global_address.website.address
  ip_protocol = "TCP"
  port_range = "80"
  target = google_compute_target_http_proxy.website.id
}

# this logs all activity related to our "my-logged-instance" instance
resource "google_logging_project_sink" "cdn-instance-sink" {
  name        = "CDN-logging-sink"
  description = "This is the bucket containing the sink for logging the CDN bucket"
  destination = "storage.googleapis.com/${google_storage_bucket.gcs-logging-bucket.name}"
  filter      = "resource.type = gce_instance AND resource.labels.instance_id = \"${google_compute_backend_bucket.website.bucket_name}\""

  unique_writer_identity = true
}

resource "google_project_iam_binding" "gcs-bucket-cdn-writer" {
  project = var.gcp_project
  role    = "roles/storage.objectCreator"

  members = [
    google_logging_project_sink.cdn-instance-sink.writer_identity,
  ]
}
