library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(shinythemes)
library(DT)
library(ggplot2)

ui <- fluidPage(
  # theme = shinytheme("cyborg"),
  navbarPage(
    title = "Shiny App Demo",
    windowTitle = "Shiny App Demo",
    id = "tabactive",
    tabPanel("Main", 
             icon = icon("table"),
             tags$body(
               dashboardPage(
                 dashboardHeader(title = "Main", disable = TRUE),
                 dashboardSidebar(
                   width = "250",
                   sidebarMenu(id = "sidebarmenu",
                               menuItem("Basic DataTable", 
                                        tabName = "menu1", 
                                        icon = icon("chart-line"))
                   ),
                   minified = FALSE
                 ),
                 dashboardBody(
                   tabItems(
                     tabItem(tabName = "menu1", 
                             # Create a new Row in the UI for selectInputs
                             fluidRow(
                               column(4,
                                      selectInput("man",
                                                  "Manufacturer:",
                                                  c("All",
                                                    unique(as.character(mpg$manufacturer))))
                               ),
                               column(4,
                                      selectInput("trans",
                                                  "Transmission:",
                                                  c("All",
                                                    unique(as.character(mpg$trans))))
                               ),
                               column(4,
                                      selectInput("cyl",
                                                  "Cylinders:",
                                                  c("All",
                                                    unique(as.character(mpg$cyl))))
                               )
                             ),
                             # Create a new row for the table.
                             DT::dataTableOutput("table")
                     )
                     
                   )
                 )
               )
             )
    )
  )
  
)

server <- shinyServer(function(input, output, session){
  
  
  # Filter data based on selections
  output$table <- DT::renderDataTable(DT::datatable({
    data <- mpg
    if (input$man != "All") {
      data <- data[data$manufacturer == input$man,]
    }
    if (input$cyl != "All") {
      data <- data[data$cyl == input$cyl,]
    }
    if (input$trans != "All") {
      data <- data[data$trans == input$trans,]
    }
    data
  }))
  
  
})

shinyApp(ui = ui, server = server)