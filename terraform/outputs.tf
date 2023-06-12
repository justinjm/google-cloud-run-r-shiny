output "service_url" {
  value = google_cloud_run_service.shinyrunapp.status[0].url
}
