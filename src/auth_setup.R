
projectId <- Sys.getenv("PROJECT_ID") 
email = Sys.getenv("GAR_AUTH_EMAIL")


library(gargle)

scope <- c("https://www.googleapis.com/auth/cloud-platform")
token <- token_fetch(scopes = scope, email = email)


library(googleAuthR)
library(googleCloudVertexAIR)

# options(googleAuthR.scopes.selected = "https://www.googleapis.com/auth/cloud-platform")

gar_auth(email = Sys.getenv("GAR_AUTH_EMAIL"),
         scopes = c("https://www.googleapis.com/auth/cloud-platform"))

result <- gcva_text_gen_predict(
  prompt="Give me ten interview questions for the role of a Python software engineer.",
  modelId="text-bison"
)

result$predictions$content