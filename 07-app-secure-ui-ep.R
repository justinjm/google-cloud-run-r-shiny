library(shiny)
library(firebase)
library(gargle)
library(bigrquery)
library(DT)

## set and print constants for use below and in logging 
cat(file = stderr(), "> project_id:", project_id <- Sys.getenv("PROJECT_ID"), "\n")
cat(file = stderr(), "> region:", region <- Sys.getenv("REGION"), "\n")
credentials_app_default(scopes="https://www.googleapis.com/auth/cloud-platform")

# firebase modals ---------------------------------------------------
sign_in <- modalDialog(
  title = "Sign in",
  textInput("email_signin", "Email"),
  passwordInput("password_signin", "Password"),
  actionButton("signin", "Sign in")
)

# ui_secure -------------------------------
ui_secure <- fluidPage(
  useFirebase(),
  actionButton("signin_modal", "Sign in"),
  shiny::uiOutput("logged_in_ui")
)


# ui_secret -------------------------------
ui_secret <- shiny::fluidPage(
  h4("Logged in!"),
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

# server -------------------------------
server <- function(input, output){
  
  f <- FirebaseEmailPassword$new()
  
  # open modal
  observeEvent(input$signin_modal, {
    showModal(sign_in)
  })
  
  observeEvent(input$signin, {
    removeModal()
    f$sign_in(input$email_signin, input$password_signin)
  })
  
  output$logged_in_ui <- shiny::renderUI({
    f$req_sign_in()
    ui_secret
  })
  
  # Function to query BigQuery and retrieve results
  queryBigQuery <- function(query) {
    query_job <- bq_project_query(project_id, query = query)
    bq_table <- bq_table_download(query_job)
    return(bq_table)
  }
  
  # Reactive expression to store the query result
  result <- eventReactive(input$submit_query, {
    query <- input$queryInput
    if (!is.null(query) && query != "") {
      tryCatch({
        queryBigQuery(query)
      }, error = function(e) {
        return(paste("Error:", e$message))
      })
    } else {
      return(data.frame())
    }
  })
  
  # Render the result in a data table
  output$tableOutput <- renderDataTable({
    f$req_sign_in()
    datatable(result(), options = list(scrollX = TRUE))
  })
  
  # Render error messages
  output$errorOutput <- renderPrint({
    f$req_sign_in()
    result()
  })
  
  
  
  
}

shiny::shinyApp(ui = ui_secure, server = server)
# https://github.com/JohnCoene/firebase/issues/5#issuecomment-1199914959