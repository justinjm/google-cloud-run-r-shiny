resource "null_resource" "print_outputs" {

  depends_on = [
    module.enable_project-services,
    # module.upload_data,
    # null_resource.upload_folder_content,
    # module.shinyrun_tables,
    # module.shinyrun_views,
    google_cloud_run_service.shinyrunapp,
    # null_resource.upload_shinyrun_notebook,
  ]
  provisioner "local-exec" {

    command = "./output.sh '${google_cloud_run_service.shinyrunapp.status[0].url}/shinyrunapp'"



  }

}
