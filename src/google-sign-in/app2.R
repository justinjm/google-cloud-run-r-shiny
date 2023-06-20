# https://lesliemyint.wordpress.com/2017/01/01/creating-a-shiny-app-with-google-login/
options(googleAuthR.scopes.selected = c("https://www.googleapis.com/auth/userinfo.email",
                                        "https://www.googleapis.com/auth/userinfo.profile"))


options("googleAuthR.webapp.client_id" = Sys.getenv("GAR_CLIENT_ID"))
options("googleAuthR.webapp.client_secret" = Sys.getenv("GAR_CLIENT_SECRET"))

library(shiny)
library(googleAuthR)
library(shinyjs)


ui <- navbarPage(
  title = "App Name",
  windowTitle = "Browser window title",
  tabPanel("Tab 1",
           useShinyjs(),
           sidebarLayout(
             sidebarPanel(
               p("Welcome!"),
               googleSignInUI("gauth_login")
             ),
             mainPanel(
               textOutput("display_username")
             )
           )
  ),
  tabPanel("Tab 2",
           p("Layout for tab 2")
  )
)

server <- function(input, output, session) {
  ## Global variables needed throughout the app
  rv <- reactiveValues(
    login = FALSE
  )
  
  ## Authentication
  accessToken <- callModule(googleSignIn, "gauth_login"
                            ,login_class = "btn btn-primary",
                            logout_class = "btn btn-primary"
                            )
  userDetails <- reactive({
    validate(
      need(accessToken(), "not logged in")
    )
    rv$login <- TRUE
    with_shiny(get_user_info, shiny_access_token = accessToken())
  })
  
  ## Display user's Google display name after successful login
  output$display_username <- renderText({
    validate(
      need(userDetails(), "getting user details")
    )
    userDetails()$displayName
  })
  
  ## Workaround to avoid shinyaps.io URL problems
  observe({
    if (rv$login) {
      shinyjs::onclick("gauth_login-googleAuthUi",
                       shinyjs::runjs("window.location.href = 'http://localhost:5001/';"))
    }
  })
}

shinyApp(ui = ui, server = server)