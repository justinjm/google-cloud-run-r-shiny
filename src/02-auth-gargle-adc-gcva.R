
library(gargle)
library(googleCloudVertexAIR)

cat("project_id:", project_id <- Sys.getenv("PROJECT_ID"), "\n")
cat("dataset_id:", dataset_id <- Sys.getenv("DATASET_ID"), "\n")
cat("billing_project_id:", billing_project_id <- Sys.getenv("BILLING_PROJECT_ID"), "\n")
cat("region:", region <- Sys.getenv("REGION"), "\n")

credentials_app_default(scopes="https://www.googleapis.com/auth/cloud-platform")


gcva_text_gen_predict(
  projectId = project_id,
  locationId = region,
  prompt="Give me ten interview questions for the role of a Python software engineer.",
  modelId="text-bison"
)