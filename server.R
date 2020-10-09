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

pop_income_data <- read.csv(file = "pop_income_data.csv")

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
      
      mutate(latitude = case_when(Region == "Alberta" ~ 55.000000, 
                                  Region == "British Columbia" ~ 53.726669,
                                  Region == "Manitoba" ~ 56.415211,
                                  Region == "New Brunswick" ~ 46.498390,
                                  Region == "Newfoundland and Labrador" ~ 53.135509,
                                  Region == "Northwest territories" ~ 62.453972,
                                  Region == "Nova Scotia" ~ 45.000000,
                                  Region == "Nunavut" ~ 63.746693,
                                  Region == "Ontario" ~ 50.000000,
                                  Region == "Prince Edward Island" ~ 46.250000,
                                  Region == "Quebec" ~ 53.000000,
                                  Region == "Saskatchewan" ~ 55.000000,
                                  Region == "Yukon" ~ 60.7212,
                                  TRUE ~ NA_real_),
             longitude = case_when(Region == "Alberta" ~ -115.000000, 
                                   Region == "British Columbia" ~ -127.647621,
                                   Region == "Manitoba" ~ -98.739075,
                                   Region == "New Brunswick" ~ -66.159668,
                                   Region == "Newfoundland and Labrador" ~ -57.660435,
                                   Region == "Northwest territories" ~ -114.371788,
                                   Region == "Nova Scotia" ~ -63.000000,
                                   Region == "Nunavut" ~ -68.516968,
                                   Region == "Ontario" ~ -85.000000,
                                   Region == "Prince Edward Island" ~ -63.000000,
                                   Region == "Quebec" ~ -70.000000,
                                   Region == "Saskatchewan" ~ -106.000000,
                                   Region == "Yukon" ~ 135.0568,
                                   TRUE ~ NA_real_))
    
  })
  
  output$map1 <- renderLeaflet({
    leaflet(filtered2()) %>% setView(lat = 60.55, lng = -70.98, zoom = 3) %>%
      addProviderTiles(providers$CartoDB.Positron,
                       
                       options = providerTileOptions(noWrap = TRUE)) %>%
      
      addLegend("bottomright", pal = colorBin(palette = c(brewer.pal(6, "Oranges")[1], brewer.pal(6, "Oranges")[6]),
                                              domain = filtered2()$pop_growth),
                values = ~pop_growth, title = "Population Growth Rate") %>%
      
      addCircles(lng = ~jitter(longitude, factor = 0), lat = ~jitter(latitude, factor = 0.01),
                 
                 fillOpacity = 0.8, radius = ~pop_growth*4000,
                 popup = ~paste(sep = "", "<b>", "Region: ", "</b>", Region, "</b><br/>", "<b>", "Population Growth Rate: ", "</b>",
                                pop_growth, "%", "</b><br/>", "<b>",
                                "Population in ", "</b>", "<b>", input$YearInput, "</b>", "<b>", ": ", "</b>", pop1, "</b><br/>", "<b>",
                                "Population in ", "</b>", "<b>", input$YearInput2, "</b>", "<b>", ": ", "</b>", pop2, "</b><br/>"), stroke = FALSE,
                 
                 color = ~colorBin(palette = c(brewer.pal(6, "Oranges")[1], brewer.pal(6, "Oranges")[6]),
                                   domain = filtered2()$pop_growth)(pop_growth))
  })
    
  output$map2 <- renderLeaflet({
    leaflet(filtered2()) %>% setView(lat = 60.55, lng = -70.98, zoom = 3) %>%
      addProviderTiles(providers$CartoDB.Positron,
                       
                       options = providerTileOptions(noWrap = TRUE)) %>%
      
      addLegend("bottomright", pal = colorBin(palette = c(brewer.pal(6, "Oranges")[1], brewer.pal(6, "Oranges")[6]),
                                              domain = filtered2()$inc_growth),
                values = ~inc_growth, title = "Income Growth Rate") %>%
      
      addCircles(lng = ~longitude, lat = ~latitude,
                 
                 fillOpacity = 0.8, radius = ~inc_growth*800,
                 popup = ~paste(sep = "", "<b>", "Region: ", "</b>", Region, "</b><br/>", "<b>", "Income Growth Rate: ", "</b>",
                                inc_growth, "%", "</b><br/>", "<b>",
                                "Household Income in ", "</b>", "<b>", input$YearInput, "</b>", "<b>", ": ", "</b>", inc1, "</b><br/>", "<b>",
                                "Household Income in ", "</b>", "<b>", input$YearInput2, "</b>", "<b>", ": ", "</b>", inc2, "</b><br/>"), stroke = FALSE,
                 
                 color = ~colorBin(palette = c(brewer.pal(6, "Oranges")[1], brewer.pal(6, "Oranges")[6]),
                                   domain = filtered2()$inc_growth)(inc_growth))
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
                 pointFormat = "<b>{point.name}</b><br>
                 Population: {point.value:,.0f}<br>
                 Income Per Capita: ${point.colorValue:,.0f}")
  })
  
  output$table <- DT::renderDataTable({
    
    filtered()[,c("Region", "Year", "Population", "Income")]}, options = list(scrollX = TRUE))
}
