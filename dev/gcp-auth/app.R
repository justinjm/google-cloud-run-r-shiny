# load packages ------------------------------------------------------------
library(shiny)
library(gargle)
library(bigrquery)
library(DBI)

cat(project_id <- Sys.getenv("PROJECT_ID"))
cat(dataset_id <- Sys.getenv("DATASET_ID"))
cat(billing_project_id <- Sys.getenv("BILLING_PROJECT_ID"))

# authenticate ------------------------------------------------------------
credentials_app_default(scopes="https://www.googleapis.com/auth/cloud-platform")

ui <- fluidPage(
  # textInput("project_id", "GCP Project ID"),
  # textInput("dataset_id", "BQ dataset"),
  # textInput("billing_project_id", "GCP Project for Billing"),
  textAreaInput("query", "SQL query"),
  actionButton("submit", "Submit query"),
  dataTableOutput("queryResults")
)


server <- function(input, output, session) {
  # json="path/to/servicetoken.json"
  # bigrquery::bq_auth(path = json)
  
  con <- dbConnect(
    bigquery(),
    project = project_id,
    dataset = dataset_id,
    billing = billing_project_id
  )
  
  query <- eventReactive(input$submit, input$query)
  
  output$queryResults <- renderDataTable({
    query <- query()
    dbGetQuery(con, query)
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
