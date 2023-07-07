# app.R -----------------------------------------------------------------------
library(shiny)
library(googleAuthR)
library(googleCloudVertexAIR)

## set these options to help debugging
# options(gargle_verbosity = "debug")
# options(googleAuthR.verbose = 2)

## set and print constants for use below and in logging 
cat(file = stderr(), "> project_id:", project_id <- Sys.getenv("PROJECT_ID"), "\n")
cat(file = stderr(), "> region:", region <- Sys.getenv("REGION"), "\n")

# authenticate ------------------------------------------------------------
#' Custom function to choose auth based on where app running, can run on local
#' machine and in cloud run without code changes 
custom_google_auth <- function() {
  sysname <- Sys.info()[["sysname"]]
  cat(file = stderr(), paste0("> sysname: ", sysname), "\n")
  if (sysname == "Linux") {
    googleAuthR::gar_gce_auth()
  }
  if (sysname == "Darwin") {
    googleAuthR::gar_auth(email = Sys.getenv("GAR_AUTH_EMAIL"),
                          scopes = "https://www.googleapis.com/auth/cloud-platform")
  }
  else {
    cat("Not running on Linux or macOS, aborting auth...")
  }
}
custom_google_auth()

## check if token exists after auth for debugging purposes
cat(file = stderr(), paste0("> Does a gar token exist: ", googleAuthR::gar_has_token()), "\n")

# TODO - update / fix / remove
# js <- '
# $(document).keyup(function(event) {
#     if ($("#user_message").is(":focus") && (event.keyCode == 13)) {
#         $("#send_message").click();
#     }
# });
# '

## UI -----------------------------------------------------------------------
ui <- fluidPage(
  # TODO - update / fix / remove
  # tags$script(HTML(js)),
  div(
    titlePanel("Vertex AI GenAI App Demo"),
    style = "color: white; background-color: #4285f4"
  ),
  sidebarLayout(
    sidebarPanel(
      h3("Welcome to a Vertex AI Demo Shiny App!"),
      p("This application allows you interact with Vertex AI Generative APIs for text. Fill out the inputs below and then ask a question to the right."),
      tags$p("Learn more about Generative AI on Vertex AI ", 
             tags$a(href = "https://cloud.google.com/vertex-ai/docs/generative-ai/learn/overview", target="_blank", "here")
      ),
      tags$hr(),
      selectInput("model_name", "Model Name",
                  choices = c("text-bison"), selected = "text-bison"),
      tags$hr(),
      sliderInput("temperature", "Temperature", min = 0.1, max = 1.0, value = 0.2, step = 0.1),
      sliderInput("max_length", "Maximum Length", min = 1, max = 1024, value = 256, step = 1),
      sliderInput("top_k", "Top-K", min = 1, max = 40, value = 40, step = 1),
      sliderInput("top_p", "Top-P", min = 0, max = 1, value = .8, step = 0.01),
      tags$hr(),
      tags$div(
        style="text-align:center; margin-top: 15px; color: white; background-color: #FFFFFF",
        a(href="https://github.com/justinjm/google-cloud-run-r-shiny", target="_blank",
          img(src="https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png", height="30px"),
          "View source code on Github"
        )
      ),
      style = "background-color: #1a1b1f; color: white"
    )
    ,
    mainPanel(
      tags$style(type = "text/css", ".shiny-output-error {visibility: hidden;}"),
      tags$style(type = "text/css", ".shiny-output-error:before {content: ' Check your inputs or authentication';}"),
      tags$style(type = "text/css", "label {font-weight: bold;}"),
      fluidRow(
        column(12,tags$h3("Chat History"),tags$hr(),uiOutput("chat_history"),tags$hr())
      ),
      fluidRow(
        column(11,textAreaInput(inputId = "user_message", placeholder = "Enter your message:", label="Prompt", width = "100%")),
        column(1,actionButton("send_message", "Submit", icon = icon("play"),height = "350px"))
      ),style = "background-color: #519BF7")
  ),style = "background-color: #3d3f4e")


## server ------------------------------------------------------------------
server <- function(input, output, session) {
  chat_data <- reactiveVal(data.frame())
  
  observeEvent(input$send_message, {
    if (input$user_message != "") {
      new_data <- data.frame(source = "User", message = input$user_message, stringsAsFactors = FALSE)
      chat_data(rbind(chat_data(), new_data))
      
      api_res <- gcva_text_gen_predict(
        projectId = project_id,
        locationId = region,
        prompt=input$user_message,
        modelId=input$model_name,
        temperature = input$temperature,
        maxOutputTokens=input$max_length,
        topP=input$top_p,
        topK=input$top_k
      )
      
      if (!is.null(api_res)) {
        api_data <- data.frame(source = "Response:", message = api_res, stringsAsFactors = FALSE)
        chat_data(rbind(chat_data(), api_data))
      }
      updateTextInput(session, "user_message", value = "")
    }
  })
  
  output$chat_history <- renderUI({
    chatBox <- lapply(1:nrow(chat_data()), function(i) {
      tags$div(class = ifelse(chat_data()[i, "source"] == "User", "alert alert-secondary", "alert alert-success"),
               HTML(paste0("<b>", chat_data()[i, "source"], ":</b> ", chat_data()[i, "message"])))
    })
    do.call(tagList, chatBox)
  })
  
  observeEvent(input$download_button, {
    if (nrow(chat_data()) > 0) {
      session$sendCustomMessage(type = "downloadData", message = "download_data")
    }
  })
}

## initialize  -------------------------------------------------------------
shinyApp(ui = ui, server = server)