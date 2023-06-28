ui_secure <- fluidPage(
  useFirebase(), # import dependencies
  firebaseUIContainer(),
  
  shiny::uiOutput("logged_in_ui")
)

ui_secret <- shiny::fluidPage(
  h4("Logged in!")
)

server <- function(input, output){
  
  f <- FirebaseUI$
    new()$ # instantiate
    set_providers( # define providers
      email = TRUE,
      google = TRUE
    )$
    launch() # launch
  
  output$logged_in_ui <- shiny::renderUI({
    f$req_sign_in()
    ui_secret
  })
}

shiny::shinyApp(ui = ui_secure, server = server)
# https://github.com/JohnCoene/firebase/issues/5#issuecomment-1199914959