/*********************************************
    Generate .Renviron files with updated info
 *********************************************/

resource "null_resource" "update_Renviron" {

  provisioner "local-exec" {
    command = "echo -e 'PROJECT_ID=${var.shinyrun_project_id}\nDATASET=${var.shinyrun_dataset_name}_views' >> ../build/app/.Renviron"

  }
}


/*********************************************
    Build the Container Registry
 *********************************************/


# resource "null_resource" "create_shinyrun_container" {

#   depends_on = [
#     module.enable_project-services,
#     null_resource.update_Renviron,
#   ]

#   provisioner "local-exec" {
#     command = "gcloud builds submit --tag us.gcr.io/${var.shinyrun_project_id}/shinyrun/shinyrun:latest --project ${var.shinyrun_project_id} ../app/."


#   }
# }


/* module "create_shinyrun_container" {

  depends_on = [
    module.enable_project-services,
  ]
  source           = "terraform-google-modules/gcloud/google"
  version          = "~> 2.0"
  platform         = "linux"
  enabled          = true
  create_cmd_body  = "builds submit --tag us.gcr.io/${var.shinyrun_project_id}/app:v1 --project ${var.shinyrun_project_id}"
  destroy_cmd_body = "container images delete us.gcr.io/${var.shinyrun_project_id}/app --force-delete-tags"

} */


/*********************************************
   Deploy App Cloud Run
 *********************************************/


resource "google_cloud_run_service" "shinyrunapp" {

  depends_on = [
    module.enable_project-services,
    null_resource.create_shinyrun_container,
  ]

  name     = "shinyrun-srv"
  location = var.shinyrun_cr_region
  project = var.shinyrun_project_id

  template {
    spec {
      containers {
        image = "us.gcr.io/${var.shinyrun_project_id}/shinyrun/shinyrun:latest"
        resources {
          limits = {
            cpu    = "2"
            memory = "2G"
          }
        }
      }
    }
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.shinyrunapp.location
  project     = google_cloud_run_service.shinyrunapp.project
  service     = google_cloud_run_service.shinyrunapp.name
  policy_data = data.google_iam_policy.noauth.policy_data
}
