library(googleAuthR)
library(googleCloudVertexAIR)


projectId <- Sys.getenv("PROJECT_ID") 
gcva_region_set(region = Sys.getenv("REGION"))
gcva_project_set(projectId = projectId)

options(googleAuthR.scopes.selected = "https://www.googleapis.com/auth/cloud-platform")

gar_auth(email = Sys.getenv("GAR_AUTH_EMAIL"))

result <- gcva_text_gen_predict(
  prompt="Give me ten interview questions for the role of a Python software engineer.",
  modelId="text-bison"
)

result$predictions$content
