
# load packages -----------------------------------------------------------
library(gargle)
library(googleCloudStorageR)
library(bigrquery)
library(googleCloudVertexAIR)

# set options and constants -----------------------------------------------
project_id <- Sys.getenv("PROJECT_ID")
location_id <- Sys.getenv("REGION")
gcva_project_set(project_id)
gcva_region_set(location_id)
# options(googleAuthR.verbose = 2)
# options(gargle_verbosity = "debug")

# authenticate ------------------------------------------------------------
## workaround for googleCloudStorage auth: 
## https://github.com/cloudyr/googleCloudStorageR/issues/131
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
vertex_datasets <- gcva_list_datasets()
vertex_datasets

# Call Vertex LLM API  
result <- gcva_text_gen_predict(
  prompt="Give me ten interview questions for the role of a Python software engineer.",
  modelId="text-bison"
)

cat(result)
