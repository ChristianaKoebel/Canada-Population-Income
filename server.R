library(shiny)
library(shinydashboard)
require(devtools)
library(dplyr)
library(tidyverse)
library(htmltools)
library(htmlwidgets)
library(leaflet)
library(data.table)
library(DT)
library(googleVis)
library(highcharter)
library(RColorBrewer)
library(rgdal)
library(sf)

can_prov <- rgdal::readOGR("canada_provinces.geojson")

can_prov$PRENAME <- as.character(can_prov$PRENAME)

pop_income_data <- read.csv(file = "pop_income_data.csv")

pop_income_data$Region <- as.character(pop_income_data$Region)

pop_income_data$Region[pop_income_data$Region == "Northwest territories"] <- "Northwest Territories"

function(input, output){
  
  output$Year <- renderUI({
    # create dropdown menu for year (map)
    div(selectInput(inputId = "YearInput", label = "Select Year",
                    
                    choices = unique(pop_income_data["Year"]),
                    
                    selected = unique(pop_income_data["Year"])[[1]][1]), style = "font-size: 17px;")
  })
  
  output$Year2 <- renderUI({
    # create second dropdown menu for year (map)
    div(selectInput(inputId = "YearInput2", label = "Select Another Year",
                    
                    choices = unique(pop_income_data["Year"]),
                    
                    selected = unique(pop_income_data["Year"])[[1]][2]), style = "font-size: 17px;")
  })
  
  output$Year3 <- renderUI({
    # create dropdown menu for year (treemap)
    div(selectInput(inputId = "YearInput3", label = "Select Year",
                    
                    choices = unique(pop_income_data["Year"]),
                    
                    selected = unique(pop_income_data["Year"])[[1]][1]), style = "font-size: 17px;")
  })
  
  filtered <- reactive({
    
    pop_income_data %>%
      
      filter(
        pop_income_data$Year %in% input$YearInput3
      )
  })
  
  filtered2 <- reactive({
    
    validate(
      need(input$YearInput != input$YearInput2, "Please select two different years")
    )
    
    pop_income_data %>%
      
      filter(
        (pop_income_data$Year %in% input$YearInput) | 
          (pop_income_data$Year %in% input$YearInput2)
      ) %>%
    
      reshape(idvar = "Region", timevar = "Year",
                direction = "wide") %>%
      
      setNames(.,c("Region", "pop1", "inc1", "pop2", "inc2")) %>%
      
      mutate(pop_growth = round((pop2 -pop1)/(pop1)*100, 2),
             inc_growth = round((inc2 -inc1)/(inc1)*100, 2)) %>%
      
      mutate(labs1 = lapply(seq(nrow(.)), function(i) {
        paste0("<b>", "Region: ", "</b>", .[i, "Region"], "</b><br/>", 
              "<b>", "Population Growth Rate: ", "</b>", .[i, "pop_growth"], "%", "</b><br/>", 
              "<b>", "Population in ", "</b>", "<b>", input$YearInput, "</b>", "<b>", ": ", "</b>", .[i, "pop1"], "</b><br/>", 
              "<b>", "Population in ", "</b>", "<b>", input$YearInput2, "</b>", "<b>", ": ", "</b>", .[i, "pop2"], "</b><br/>")}),
        labs2 = lapply(seq(nrow(.)), function(i) {
          paste0("<b>", "Region: ", "</b>", .[i, "Region"], "</b><br/>", 
                "<b>", "Income Growth Rate: ", "</b>", .[i, "inc_growth"], "%", "</b><br/>", 
                "<b>", "Income in ", "</b>", "<b>", input$YearInput, "</b>", "<b>", ": ", "</b>", .[i, "inc1"], "</b><br/>", 
                "<b>", "Income in ", "</b>", "<b>", input$YearInput2, "</b>", "<b>", ": ", "</b>", .[i, "inc2"], "</b><br/>")})) %>%
             
      merge(can_prov, ., by.x = "PRENAME", 
            by.y = "Region", duplicateGeoms = TRUE)
    
  })
  
  output$map1 <- renderLeaflet({
    leaflet(filtered2()) %>%
    
      addTiles() %>%
      
      addPolygons(smoothFactor = 0.3, weight = 2, opacity = 1, color = "white", 
                  dashArray = "3", fillOpacity = 0.7,
                  highlight = highlightOptions(
                    weight = 2,
                    color = "#666",
                    dashArray = "",
                    fillOpacity = 0.7,
                    bringToFront = TRUE),
                  fillColor = ~colorBin(palette = c(brewer.pal(6, "Oranges")[1], brewer.pal(6, "Oranges")[6]),
                                        domain = filtered2()$pop_growth)(pop_growth),
                  label = lapply(filtered2()$labs1, htmltools::HTML)) %>%
      
      addLegend("bottomright", pal = colorBin(palette = c(brewer.pal(6, "Oranges")[1], brewer.pal(6, "Oranges")[6]),
                                              domain = filtered2()$pop_growth),
                values = ~pop_growth, title = "Population Growth Rate")
      
  })
    
  output$map2 <- renderLeaflet({
    leaflet(filtered2()) %>%
      
      addTiles() %>%
      
      addPolygons(smoothFactor = 0.3, weight = 2, opacity = 1, color = "white", 
                  dashArray = "3", fillOpacity = 0.7,
                  highlight = highlightOptions(
                    weight = 2,
                    color = "#666",
                    dashArray = "",
                    fillOpacity = 0.7,
                    bringToFront = TRUE),
                  fillColor = ~colorBin(palette = c(brewer.pal(6, "Oranges")[1], brewer.pal(6, "Oranges")[6]),
                                        domain = filtered2()$inc_growth)(inc_growth),
                  label = lapply(filtered2()$labs2, htmltools::HTML)) %>%
      
      addLegend("bottomright", pal = colorBin(palette = c(brewer.pal(6, "Oranges")[1], brewer.pal(6, "Oranges")[6]),
                                              domain = filtered2()$inc_growth),
                values = ~inc_growth, title = "Income Growth Rate")
    
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
      
      hc_colorAxis(minColor = brewer.pal(9, "Oranges")[1],
                   maxColor = brewer.pal(9, "Oranges")[9]) %>% 
      
      hc_legend(borderWidth = 2, borderColor = "black", width = 265, symbolWidth = 260,
                title = list(text = "Household Income per Capita",
                             style = list(fontWeight = 'bold', fontSize = 15))) %>%
      
      hc_chart(style = list(fontFamily = 'Calibri', fontSize = 16)) %>%
      
      hc_tooltip(borderColor = "black", style = list(fontFamily = 'Calibri', fontSize = 16, lineHeight = 20),
                 pointFormat = "<b>Region:</b> {point.name}<br>
                 <b>Population:</b> {point.value:,.0f}<br>
                 <b>Income Per Capita:</b> ${point.colorValue:,.0f}")
  })
  
  output$table <- DT::renderDataTable({
    
    filtered()[,c("Region", "Year", "Population", "Income")]}, options = list(scrollX = TRUE))
}
