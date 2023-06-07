library(shiny)
library(gargle)
library(bigrquery)
library(DT)

# Define your BigQuery project and dataset
# project_id <- "your-project-id"
# dataset <- "your-dataset"
cat("project_id:", project_id <- Sys.getenv("PROJECT_ID"), "\n")
cat("dataset_id:", dataset_id <- Sys.getenv("DATASET_ID"), "\n")
credentials_app_default(scopes="https://www.googleapis.com/auth/cloud-platform")


# UI
ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      textInput("queryInput", "SQL Query"),
      actionButton("submitBtn", "Submit")
    ),
    mainPanel(
      fluidRow(
        column(width = 12, dataTableOutput("tableOutput"))
      ),
      fluidRow(
        column(width = 12, verbatimTextOutput("errorOutput"))
      )
    )
  )
)

# Server
server <- function(input, output) {
  
  # Function to query BigQuery and retrieve results
  queryBigQuery <- function(query) {
    query_job <- bq_project_query(project = project_id, query = query)
    bq_table <- bq_table_download(query_job)
    return(bq_table)
  }
  
  # Reactive expression to store the query result
  result <- reactive({
    query <- input$queryInput
    if (!is.null(query) && query != "") {
      tryCatch({
        queryBigQuery(query)
      }, error = function(e) {
        return(paste("Error:", e$message))
      })
    }
  })
  
  # Render the result in a table
  output$tableOutput <- renderDataTable({
    datatable(result(), options = list(scrollX = TRUE))
  })
  
  # Render error messages
  output$errorOutput <- renderPrint({
    result()
  })
  
  # Handle submit button click event
  ## TODO - Fix error 
  observeEvent(input$submitBtn, {
    output$tableOutput <- renderDataTable({
      datatable(result(), options = list(scrollX = TRUE))
    })
  })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)
