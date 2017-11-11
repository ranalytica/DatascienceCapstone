#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
# Define UI for application that draws a histogram
shinyUI(fluidPage(
    # Application title
    titlePanel("NextIT Word Predictor v1.0.0"),
    
    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            textInput(
                "inputString",
                "Type something and enter space",
                value = "",
                placeholder = "Type Here"
            )
        ),
        
        # Show a plot of the generated distribution
        mainPanel(
        
            verbatimTextOutput("value"),
            verbatimTextOutput("value2")

        )
    )
))
