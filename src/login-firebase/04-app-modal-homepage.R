library(shiny)
library(shinyjs)
library(waiter)
library(firebase)

homepageUI <- function(id) {
  ns <- NS(id)
  fluidPage(
    hidden(
      div(id= ns('homepage_div'))
    )
  )
}

homepageServer <- function(input, output, session) {
  # Put your server-side code for the homepage here
   output$plot <- renderPlot({
  # f$req_sign_in() # require sign in
  plot(cars)
   })
}

ui <- fluidPage(
  autoWaiter(),
  useFirebase(),
  homepageUI("homepage")
)

server <- function(input, output, session) {
  showModal(
    div(
      # Sys.sleep(2),
      useFirebase(),
      firebaseUIContainer()
    )
  )
  
  f <- FirebaseUI$
    new("session")$ # instantiate
    set_providers( # define providers
      email = TRUE,
      google = TRUE
    )$
    launch() # launch
  
  observeEvent(f$get_signed_in(),{
    if(isFALSE(f$get_signed_in()))
      return()
    removeModal()
    show("homepage_div")
    callModule(homepageServer, "homepage")
  })
  
}

shiny::shinyApp(ui = ui, server = server)