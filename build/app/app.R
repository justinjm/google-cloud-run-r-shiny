library(shiny)
library(httr)
library(stringr)

library(googleAuthR)
library(googleCloudVertexAIR)


projectId <- Sys.getenv("PROJECT_ID") 
gcva_region_set(region = Sys.getenv("REGION"))
gcva_project_set(projectId = projectId)

options(googleAuthR.scopes.selected = "https://www.googleapis.com/auth/cloud-platform")

gar_auth(email = Sys.getenv("GAR_AUTH_EMAIL"))



ui <- fluidPage(
  div(
    titlePanel("Shiny App Demo"),
    style = "color: white; background-color: #4285f4"
  ),
  sidebarLayout(
    sidebarPanel(
      h3("Welcome to a Demo Shiny App!"),
      p("This application allows you test text prompts with Vertex AI.  fill out the inputs below and then ask a question to the right."),
      textInput("user_name", "User Name", "<FIRST NAME, LAST NAME>"),
      tags$p("Learn more about Generative AI on Vertex AI ", 
             tags$a(href = "https://cloud.google.com/vertex-ai/docs/generative-ai/learn/overview", target="_blank", "here")
      ),tags$hr(),
      selectInput("model_name", "Model Name",
                  choices = c("text-bison"), selected = "text-bison"),
      tags$hr(),
      sliderInput("temperature", "Temperature", min = 0.1, max = 1.0, value = 0.2, step = 0.1),
      sliderInput("max_length", "Maximum Length", min = 1, max = 8000, value = 256, step = 1),
      tags$hr(),
      textAreaInput(inputId = "sysprompt", label = "SYSTEM PROMPT",height = "200px", placeholder = "You are a helpful assistant."),
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
      tags$style(type = "text/css", ".shiny-output-error:before {content: ' Check your inputs or API key';}"),
      tags$style(type = "text/css", "label {font-weight: bold;}"),
      fluidRow(
        column(12,tags$h3("Chat History"),tags$hr(),uiOutput("chat_history"),tags$hr())
      ),
      fluidRow(
        column(11,textAreaInput(inputId = "user_message", placeholder = "Enter your message:", label="USER PROMPT", width = "100%")),
        column(1,actionButton("send_message", "Send",icon = icon("play"),height = "350px"))
      ),style = "background-color: #519BF7")
  ),style = "background-color: #3d3f4e")

server <- function(input, output, session) {
  chat_data <- reactiveVal(data.frame())
  
  observeEvent(input$send_message, {
    if (input$user_message != "") {
      new_data <- data.frame(source = "User", message = input$user_message, stringsAsFactors = FALSE)
      chat_data(rbind(chat_data(), new_data))
      
      api_res <- gcva_text_gen_predict(
        prompt=input$user_message,
        modelId=input$model_name,
        temperature = input$temperature,
        maxOutputTokens=input$max_length,
        topP=0.8,
        topK=40
      )
      
      if (!is.null(api_res)) {
        api_data <- data.frame(source = "Vertex AI", message = api_res, stringsAsFactors = FALSE)
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
shinyApp(ui = ui, server = server)