/******************************************
    Enable Project Services configuration
 *****************************************/

module "enable_project-services" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  version                     = "10.1.1"
  project_id                  = var.shinyrun_project_id
  enable_apis                 = var.enable
  disable_services_on_destroy = false

  activate_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "monitoring.googleapis.com",
    "bigquery.googleapis.com",
    "storage.googleapis.com",
    "run.googleapis.com",
    "cloudbuild.googleapis.com",
    "notebooks.googleapis.com",
  ]

}


/*********************************************
   Default Svc Account
 *********************************************/

data "google_project" "project" {
  project_id = var.shinyrun_project_id
}

module "svc_prj_svc_acct_iam_bindings_in_host_project" {
  depends_on = [
    module.enable_project-services,
  ]
  source                  = "terraform-google-modules/iam/google//modules/member_iam"
  service_account_address = "${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  #prefix                  = "serviceAccount"
  project_id    = var.shinyrun_project_id
  project_roles = ["roles/bigquery.dataViewer", "roles/bigquery.jobUser"]
}
