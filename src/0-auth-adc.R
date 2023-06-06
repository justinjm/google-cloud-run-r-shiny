
library(gargle)
# library(googleCloudVertexAIR)
options(gargle_verbosity = "debug")

# token <- token_fetch(scopes = "https://www.googleapis.com/auth/cloud-platform",
#                      email =)

# bq_auth(token = token)

credentials_app_default(scopes="https://www.googleapis.com/auth/cloud-platform")

library(bigrquery)
## List bigquery datasets 
datasets <- bq_project_datasets(Sys.getenv("PROJECT_ID"))
datasets

# gcva_list_datasets(projectId = Sys.getenv("PROJECT_ID"),
#                    locationId = Sys.getenv("REGION"))

# result <- gcva_text_gen_predict(
#   projectId = Sys.getenv("PROJECT_ID"),
#   locationId = Sys.getenv("REGION"),
#   prompt="Give me ten interview questions for the role of a Python software engineer.",
#   modelId="text-bison"
# )
# 
# cat(result)
