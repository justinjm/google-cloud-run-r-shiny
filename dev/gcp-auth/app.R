# load packages ------------------------------------------------------------
library(shiny)
library(gargle)
library(bigrquery)
library(DBI)

cat(project_id <- Sys.getenv("PROJECT_ID"))
cat(dataset_id <- Sys.getenv("DATASET_ID"))
cat(billing_project_id <- Sys.getenv("BILLING_PROJECT_ID"))

cat(scopes <- "https://www.googleapis.com/auth/cloud-platform")

# authenticate ------------------------------------------------------------
# Add to `.Renviron``: `GARGLE_SVC_ACCT_JSON="path/to/servicetoken.json"`
bq_auth(path = Sys.getenv("GARGLE_SVC_ACCT_JSON"))

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
