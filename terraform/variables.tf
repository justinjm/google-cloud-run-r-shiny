variable "shinyrun_project_id" {
  description = "Name for Shiny Run project"
}


variable "shinyrun_dataset_name" {
  description = "Name for Shiny Run Dataset"
  default     = "shinyrun"
}


variable "enable" {
  description = "Actually enable the APIs listed"
  default     = true
}

variable "sampledatafolder_path" {
  description = "Sample Data"
  default     = "data/sample"
}


variable "delete_contents_on_destroy" {
  description = "(Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present."
  type        = bool
  default     = true
}

variable "shinyrun_bq_region" {
  description = "BQ Region for the Dataset"
  default     = "US"
}

variable "shinyrun_cr_region" {
  description = "Cloud Run Region for the Dataset"
  default     = "us-central1"
}

variable "shinyrun_nb_zone" {
  description = "Cloud Run Region for the Dataset"
  default     = "us-central1-b"
}

variable "shinyrun_notebook_name" {
  description = "Notebook Name"
  default     = "shinyrunnb"
}


variable "machine_type" {
  description = "Machine type for notebook instance"
  default     = "e2-medium"
}

variable "image_family" {
  description = "image_family for notebook instance"
  default     = "tf-latest-cpu"
}





