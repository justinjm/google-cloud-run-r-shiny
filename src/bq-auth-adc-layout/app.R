library(shiny)
library(gargle)
library(bigrquery)
library(DT)

## set and print constants for use below and in logging 
cat(file = stderr(), "> project_id:", project_id <- Sys.getenv("PROJECT_ID"), "\n")
cat(file = stderr(), "> region:", region <- Sys.getenv("REGION"), "\n")
credentials_app_default(scopes="https://www.googleapis.com/auth/cloud-platform")
# sample query (only a few rows)
## SELECT * FROM z_test.crm_user

# UI
ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      textInput("queryInput", "Query:"),
      actionButton("submit_query", "Run Query")
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
    query_job <- bq_project_query(project_id, query = query)
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
  observeEvent(input$submit_query, {
    output$tableOutput <- renderDataTable({
      datatable(result(), options = list(scrollX = TRUE))
    })
  })
}

# Run the Shiny app
shinyApp(ui = ui, server = server)
