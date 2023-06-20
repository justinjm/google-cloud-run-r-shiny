library(shiny)
library(googleAuthR)

# TODO 
## GCP
## OAuth Client ID - Web Application - add url to Javascript origin `http://localhost:5000/`
## Local 
## add `GAR_CLIENT_ID="CLIENT-ID"` to `.Renviron` 
## when shiny app opens, change app url to be `http://localhost:5000/`
options(googleAuthR.webapp.client_id = Sys.getenv("GAR_CLIENT_ID"))

## debugging and local testing only
options(shiny.port = 5001)
options(shiny.error = browser)

ui <- fluidPage(
  
  titlePanel("Sample Google Sign-In"),
  
  sidebarLayout(
    sidebarPanel(
      googleSignInUI("demo")
    ),
    
    mainPanel(
      with(tags, dl(dt("Name"), dd(textOutput("g_name")),
                    dt("Email"), dd(textOutput("g_email")),
                    dt("Image"), dd(uiOutput("g_image")) ))
    )
  )
)

server <- function(input, output, session) {
  
  sign_ins <- shiny::callModule(googleSignIn, "demo")
  
  output$g_name = renderText({ sign_ins()$name })
  output$g_email = renderText({ sign_ins()$email })
  output$g_image = renderUI({ img(src=sign_ins()$image) })
  
}

# Run the application 
shinyApp(ui = ui, server = server)