library(shiny)
library(shinydashboard)
require(devtools)
library(dplyr)
library(tidyverse)
library(htmltools)
library(htmlwidgets)
library(data.table)
library(DT)
library(googleVis)
library(highcharter)
library(RColorBrewer)

pop_income_data <- read.csv(file = "pop_income_data.csv")

function(input, output){
  
  output$Year <- renderUI({
    # create dropdown menu for year
    div(selectInput(inputId = "YearInput", label = "Select Year",
                    
                    choices = unique(pop_income_data["Year"]),
                    
                    selected = unique(pop_income_data["Year"])[1]), style = "font-size: 17px;")
  })
  
  filtered <- reactive({
    
    pop_income_data %>%
      
      filter(
        pop_income_data$Year %in% input$YearInput
      )
  })
  
  output$tree <- renderHighchart({
    
    hctreemap2(data = filtered(),
               group_vars = c("Region"),
               size_var = "Population",
               color_var = "Income",
               layoutAlgorithm = "squarified",
               levelIsConstant = FALSE,
               drillUpButton = list(text = '<- Back to Previous Level',
                                    position = list(align = 'left')),
               borderColor = "#DCDCDC",
               levels = list(
                 list(level = 1, dataLabels = list(filter = list(property = 'value', operator = '>', value = 90000),
                                                   enabled = TRUE, style = list(fontSize = 14, 
                                                                                color = 'black', fontWeight = 'normal')))
               )) %>% 
      
      hc_colorAxis(minColor = brewer.pal(9, "RdPu")[1],
                   maxColor = brewer.pal(9, "RdPu")[9]) %>% 
      
      hc_legend(borderWidth = 2, borderColor = "black", width = 265, symbolWidth = 260,
                title = list(text = "Household Income per Capita",
                             style = list(fontWeight = 'bold', fontSize = 15))) %>%
      
      hc_chart(style = list(fontFamily = 'Calibri', fontSize = 16)) %>%
      
      hc_tooltip(borderColor = "black", style = list(fontFamily = 'Calibri', fontSize = 16, lineHeight = 20),
                 pointFormat = "<b>{point.name}</b><br>
                 Population: {point.value:,.0f}<br>
                 Income Per Capita: ${point.colorValue:,.0f}")
  })
  
  output$table <- DT::renderDataTable({
    
    filtered()[,c("Region", "Year", "Population", "Income")]}, options = list(scrollX = TRUE))
}