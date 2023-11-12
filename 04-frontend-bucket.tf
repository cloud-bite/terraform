resource "google_storage_bucket" "website" {
  name = "cb-website"
  location = "EU"
}

resource "google_storage_default_object_access_control" "website_read" {
  bucket = google_storage_bucket.website.name
  role = "READER"
  entity = "allUsers"
}
