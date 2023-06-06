
# load packages -----------------------------------------------------------
library(gargle)
library(bigrquery)
# TODO - figure out ADC
# library(googleCloudStorageR)
## TODO - package needs auth migration from googleAuthR to use ADC
# library(googleCloudVertexAIR)

# set options and constants -----------------------------------------------
options(gargle_verbosity = "debug")

project_id <- Sys.getenv("PROJECT_ID")

# authenticate ------------------------------------------------------------
credentials_app_default(scopes="https://www.googleapis.com/auth/cloud-platform")

# test connections --------------------------------------------------------
## List gcs buckets
# buckets <- gcs_list_buckets(project_id)
# buckets

## List bigquery datasets 
datasets <- bq_project_datasets(project_id)
datasets

# list vertex ai datasets  
# gcva_list_datasets(projectId = Sys.getenv("PROJECT_ID"),
#                    locationId = Sys.getenv("REGION"))

# Call Vertex LLM API  
# result <- gcva_text_gen_predict(
#   projectId = Sys.getenv("PROJECT_ID"),
#   locationId = Sys.getenv("REGION"),
#   prompt="Give me ten interview questions for the role of a Python software engineer.",
#   modelId="text-bison"
# )
# 
# cat(result)
