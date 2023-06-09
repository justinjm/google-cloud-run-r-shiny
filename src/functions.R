custom_google_auth <- function() {
  system <- Sys.info()
  cat("sysname:", system[["sysname"]], "\n")
  
  if (system[["sysname"]] == "Linux") {
    googleAuthR::gar_gce_auth()
  } 
  if (system[["sysname"]] == "Darwin") {
    googleAuthR::gar_auth(email = Sys.getenv("GAR_AUTH_EMAIL"),
                          scopes = "https://www.googleapis.com/auth/cloud-platform")
  }
  else {
    googleAuthR::gar_gce_auth()
  }
}

custom_google_auth()