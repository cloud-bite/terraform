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