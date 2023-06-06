library(shiny)
library(httr)
library(stringr)

library(googleAuthR)
library(googleCloudVertexAIR)

projectId <- Sys.getenv("PROJECT_ID") 
region <- Sys.getenv("REGION")

gcva_region_set(region = region)
gcva_project_set(projectId = projectId)

# options(googleAuthR.verbose = 0) # set when debugging
options(googleAuthR.scopes.selected = "https://www.googleapis.com/auth/cloud-platform")


# gar_set_client(web_json = "client.json")
gar_auth(email = Sys.getenv("GAR_AUTH_EMAIL"))

# https://bitbucket.org/rsmsoftware/portfolio-climate-risk-analytics-design-pattern/src/master/apps/portfolio-climate-risk-analytics_v_1.0.0.0/global.R

