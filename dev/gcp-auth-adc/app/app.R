# load packages ------------------------------------------------------------
library(shiny)
library(gargle)
library(bigrquery)
library(DBI)

cat("project_id:", project_id <- Sys.getenv("PROJECT_ID"), "\n")
cat("dataset_id:", dataset_id <- Sys.getenv("DATASET_ID"), "\n")
cat("billing_project_id:", billing_project_id <- Sys.getenv("BILLING_PROJECT_ID"), "\n")

# authenticate ------------------------------------------------------------
credentials_app_default(scopes="https://www.googleapis.com/auth/cloud-platform")

ui <- fluidPage(
  textAreaInput("query", "SQL query"),
  actionButton("submit", "Submit query"),
  dataTableOutput("queryResults")
)


server <- function(input, output, session) {
  
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
