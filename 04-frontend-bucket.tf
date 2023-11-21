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