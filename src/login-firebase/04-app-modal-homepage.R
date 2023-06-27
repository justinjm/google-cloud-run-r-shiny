


ui <-  function(id) {
  ns <- shiny::NS(id)
  fluidPage(
    autoWaiter(),
    useFirebase(),
    hidden(
      div(id= ns('homepage_div'),
          home_page$ui(ns("homepage"))
      )
    )
  )
}

server <- function(id) {
  moduleServer(id, function(input, output, session) {
    showModal(
      div(
        Sys.sleep(2),
        useFirebase(),
        firebase::firebaseUIContainer()
      )
    )
    
    
    f <- firebase::FirebaseUI$
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
      home_page$server("homepage")
    })
    
  })
}

shiny::shinyApp(ui = ui, server = server)