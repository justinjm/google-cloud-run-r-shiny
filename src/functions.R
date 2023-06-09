running_on_linux <- function() {
  system <- Sys.info()
  cat("sysname:", system[["sysname"]], "\n")
  if (system[["sysname"]] == "Linux") {
    message("Running on Linux !")
  } else {
    FALSE
  }
}

running_on_linux()