#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
library(shiny)
library(zoo)
library(ggplot2)
library(tseries)

library(TTR)
library(dplyr)
library(plotly)

# TODO : install.packages("tseries")

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  spy <- NULL
  ief <- NULL
  rollingcorr.1m.df <- NULL

  rv <- reactiveValues(show = NULL)
  
  observeEvent(input$loadStock, {
    rv$show <- "loadStock"
  })
  
  observeEvent(input$corrWindow, {
    rv$show <- "replot"
  })
  
  output$corrPlot <- renderPlotly({
    if (is.null(rv$show))
    {
      return(NULL)
    }
    
    if(identical(rv$show, "loadStock") && nchar(input$stockB) >= 4 && nchar(input$stockA) >= 4)
    {
      spy <<- get.hist.quote(instrument=input$stockA, quote="AdjClose",
                             provider="yahoo", origin="1970-01-01",
                             compression="d", retclass="zoo")
      ief <<- get.hist.quote(instrument=input$stockB, quote="AdjClose",
                             provider="yahoo", origin="1970-01-01",
                             compression="d", retclass="zoo")
    }
    
    if((identical(rv$show, "loadStock") || identical(rv$show, "replot")) &&
       (!is.null(ief) && !is.null(spy)))
    {
      z <- merge.zoo(spy,ief)
      z.logrtn <- diff(log(z))
      names(z.logrtn) <- c("spy", "ief")
      c <- cor(z.logrtn,use="complete.obs")
      ut <- upper.tri(c)
      
      rollingcorr.1m <- rollapply(z.logrtn,
                                  width=input$corrWindow,
                                  FUN = function(Z)
                                  {
                                    return(cor(Z,use="pairwise.complete.obs")[ut])
                                  },
                                  by.column=FALSE, align="right")
      rollingcorr.1m.df <<- fortify(rollingcorr.1m,melt=TRUE)
      
      if(!is.null(rollingcorr.1m.df)){
        ggplot(rollingcorr.1m.df,aes(x=Index)) +
          geom_ribbon(aes(ymin=0,ymax=Value * (Value > 0)), fill = alpha("blue", 0.3) ) +
          geom_ribbon(aes(ymin=Value * (Value < 0),ymax=0), fill = alpha("red", 0.3) ) +
          facet_grid(Series~.) +
          ylim(c(-1,1)) +
          theme_gray();
        
      }
    }else{
      return(NULL);
    }
  })
})
