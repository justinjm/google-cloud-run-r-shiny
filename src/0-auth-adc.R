
# load packages -----------------------------------------------------------
library(gargle)
library(googleCloudStorageR)
library(bigrquery)
library(googleCloudVertexAIR)

# set options and constants -----------------------------------------------
project_id <- Sys.getenv("PROJECT_ID")
# options(googleAuthR.verbose = 2)
# options(gargle_verbosity = "debug")

# authenticate ------------------------------------------------------------
## workaround for googleCloudStorage auth: 
## https://github.com/r-lib/gargle/issues/130
token <- credentials_app_default(scopes="https://www.googleapis.com/auth/cloud-platform")
gcs_auth(token = token)

# test connections --------------------------------------------------------
## List gcs buckets
buckets <- gcs_list_buckets(project_id)
buckets

## List bigquery datasets 
datasets <- bq_project_datasets(project_id)
datasets

# list vertex ai datasets  
vertex_datasets <- gcva_list_datasets(projectId = Sys.getenv("PROJECT_ID"),
                                      locationId = Sys.getenv("REGION"))
vertex_datasets

# Call Vertex LLM API  
result <- gcva_text_gen_predict(
  projectId = Sys.getenv("PROJECT_ID"),
  locationId = Sys.getenv("REGION"),
  prompt="Give me ten interview questions for the role of a Python software engineer.",
  modelId="text-bison"
)

cat(result)
