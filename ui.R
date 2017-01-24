#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(plotly)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Stock Correlation Explorer - 06.01.2017"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      textInput("stockB", "Stock A - Stock Symbol", value = "MSFT"),
      textInput("stockA", "Stock B - Stock Symbol", value = "^IXIC"),
      actionButton("loadStock", label = "Load Stock", width = "100%"),
      sliderInput("corrWindow", min=2, max=730, step = 1, value = 90, label = "Correlation Window (days)")

    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      div(
        HTML(
          paste(
            "<b>Instructions</b></br>
            Correlation is about the relationship of two random variables. Correlation can indicate
            a predictive Relationship. However, if you only take a certain window of the past into 
            consideration you examine the rolling correlation. The rolling correlation is not a 
            constant value, it changes over time, getting more stable the longer the window is.</br>
            You can enter two stock symbols from <a href=\"finance.yahoo.com\">Yahoo finance</a>
            into the textboxes below
            and load them by pressing the button.</br>
            The financial data is downloaded from yahoo, so it can take a moment before the plot shown.
            With the slider you can change the window size in days for the calculation of 
            the rolling correlation between 2 days and 730 days.</br>
            Two combinations are for ex:
            </br><ul><li>(Microsoft:MSFT, Nasdaq Composite:^IXIC)</li>
            <li>(CBOE Interest Rate 10 Year T Note:^TNX, Nasdaq Composite:^IXIC)</li></ul>"
          )
        ), align="justify", border="1"
      ),
      plotlyOutput("corrPlot")
    )
  )
))
