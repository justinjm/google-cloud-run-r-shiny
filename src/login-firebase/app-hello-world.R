library(shiny)
library(firebase)

ui <- fluidPage(
  useFirebase(), # import dependencies
  firebaseUIContainer()
)

server <- function(input, output){
  f <- FirebaseUI$
    new()$ # instantiate
    set_providers( # define providers
      email = TRUE, 
      google = TRUE
    )$
    launch() # launch
}

shinyApp(ui, server)
