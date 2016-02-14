#

library(shiny)

dataSets <- c("faithful", "mtcars", "morley", "rock")

# Define UI for application that draws a histogram
ui <- shinyUI(fluidPage(
   
   # Application title
   titlePanel("Histogram Slider for Selected Data"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         selectInput("dataset",
                     "Select a dataset",
                     choices=as.list(dataSets)), 
          
         sliderInput("bins",
                     "Number of bins:",
                     min = 1,
                     max = 50,
                     value = 30)
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("distPlot")
      )
   )
))

# Define server logic required to draw a histogram
server <- shinyServer(function(input, output) {
   
   output$distPlot <- renderPlot({
      # dataset
      z <- get(input$dataset)
      # generate bins based on input$bins from ui.R
      #x    <- faithful[, 2]
      x <- z[,2,drop=TRUE]
      bins <- seq(min(x), max(x), length.out = input$bins + 1)
      
      # draw the histogram with the specified number of bins
      hist(x, breaks = bins, col = 'darkgray', border = 'white')
   })
})

# Run the application 
shinyApp(ui = ui, server = server)

