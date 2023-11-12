resource "google_compute_global_address" "website" {
  name = "website-lb-ip"
}

resource "google_dns_managed_zone" "gcp_cb" {
  name = "gcp-cb"
  dns_name = "gcp-cb.com."
  
}

resource "google_dns_record_set" "website" {
  name = "website.${google_dns_managed_zone.gcp_cb.dns_name}"
  type = "A"
  ttl = 300
  managed_zone = google_dns_managed_zone.gcp_cb.name
  rrdatas = [google_compute_global_address.website.address]
}

resource "google_compute_backend_bucket" "website" {
  name = "website-backend"
  description = "Contains files needed by the website"
  bucket_name = google_storage_bucket.website.name
  enable_cdn = true
}

resource "google_compute_managed_ssl_certificate" "website" {
  name = "website-cert"
  managed {
    domains = [google_dns_record_set.website.name]
  }
}

resource "google_compute_url_map" "website" {
  name = "website-url-map"
  default_service = google_compute_backend_bucket.website.self_link
}

resource "google_compute_target_https_proxy" "website" {
  name = "website-target-proxy"
  url_map = google_compute_url_map.website.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.website.self_link]
}

resource "google_compute_global_forwarding_rule" "default" {
  name = "website-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address = google_compute_global_address.website.address
  ip_protocol = "TCP"
  port_range = "443"
  target = google_compute_target_https_proxy.website.self_link
}