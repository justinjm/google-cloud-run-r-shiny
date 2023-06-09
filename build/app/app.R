# app.R -----------------------------------------------------------------------
library(shiny)
library(googleCloudStorageR)
library(bigrquery)
library(googleCloudVertexAIR)

# options(gargle_verbosity = "debug")
# options(googleAuthR.verbose = 2)

cat("project_id:", project_id <- Sys.getenv("PROJECT_ID"), "\n")
cat("dataset_id:", dataset_id <- Sys.getenv("DATASET_ID"), "\n")
cat("billing_project_id:", billing_project_id <- Sys.getenv("BILLING_PROJECT_ID"), "\n")
cat("region:", region <- Sys.getenv("REGION"), "\n")

# authenticate ------------------------------------------------------------
## function to choose auth based on where app running, can run on local machine
## and in cloud run without code changes 
custom_google_auth <- function() {
  system <- Sys.info()
  cat("sysname:", system[["sysname"]], "\n")
  
  if (system[["sysname"]] == "Linux") {
    googleAuthR::gar_gce_auth()
  } 
  if (system[["sysname"]] == "Darwin") {
    googleAuthR::gar_auth(email = Sys.getenv("GAR_AUTH_EMAIL"),
                          scopes = "https://www.googleapis.com/auth/cloud-platform")
  }
  else {
    googleAuthR::gar_gce_auth()
  }
}

custom_google_auth()

## check if token exists after auth for debugging purposes
cat(file = stderr(), paste0("Does a gar token exist: ", googleAuthR::gar_has_token()), "\n")

## UI -----------------------------------------------------------------------
# Uncomment below lines to install required packages if not already installed
# install.packages("shiny")
# install.packages("bigrquery")
# install.packages("googleCloudVertexAIR")

# Load the necessary packages
library(shiny)
library(bigrquery)
library(googleCloudVertexAIR)

# Start the shiny app
# shinyApp(
ui <- fluidPage(
  titlePanel("BigQuery and Vertex AI Integration"),
  sidebarLayout(
    sidebarPanel(
      textInput("user_input1", "Enter your text:"),
      actionButton("submit_button1", "Submit"),
      verbatimTextOutput("response1"),
      textInput("user_input2", "Verify response:"),
      actionButton("submit_button2", "Submit")
    ),
    mainPanel(
      textOutput("response2")
    )
  )
)
## server ------------------------------------------------------------------
server <- function(input, output) {
  response1_data <- eventReactive(input$submit_button1, {
    # Put your BigQuery query here, with input$user_input1 as a parameter
    query <- paste("SELECT * FROM dataset WHERE filter = '", input$user_input1, "'", sep = "")
    # Assumes you have your authentication set up already
    response <- bigrquery::bigrquery(query)
    return(response)
  })
  
  output$response1 <- renderPrint({
    response1_data()
  })
  
  response2_data <- eventReactive(input$submit_button2, {
    # Send the response to the Vertex AI
    response <- googleCloudVertexAIR::predict_text(response1_data(), input$user_input2)
    return(response)
  })
  
  output$response2 <- renderText({
    response2_data()
  })
}





## initialize  -------------------------------------------------------------
shinyApp(ui = ui, server = server)