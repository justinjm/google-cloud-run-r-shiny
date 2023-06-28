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
}

shiny::shinyApp(ui = ui_secure, server = server)
# https://github.com/JohnCoene/firebase/issues/5#issuecomment-1199914959