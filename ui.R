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

dashboardPage(
  
  skin = "red",
  
  dashboardHeader(
    
    tags$li(class = "dropdown",
            tags$style(".main-header {max-height: 50px}"),
            tags$style(".main-header .logo {height: 50px}"),
            tags$style(".sidebar-toggle {height: 20px; padding-top: 30px !important;}"),
            tags$style(".navbar {min-height:20px !important}")),
    
      titleWidth = "150px", title = tags$a(href="https://github.com/ChristianaKoebel/RShiny-Treemap-Population-Income", 
                                          tags$img(height = "30px", src = "logo.png"))),
  
  dashboardSidebar(disable = TRUE),
  
  dashboardBody(
    
    tags$head(
      
      tags$style(type = 'text/css', 
                 
                 ".selectize-input {font-size: 15px; line-height: 25px;} 
                 
                 .selectize-dropdown {font-size: 15px; line-height: 25px;}
                 
                 #tree {height: calc(100vh - 80px) !important;}
                 
                 # map1 {height: calc(100vh - 80px) !important;}
                 
                 # map2 {height: calc(100vh - 80px) !important;}
                 
                 "),
      
      tags$style('
      
                 .leaflet-popup-content-wrapper {
                  font-size: 15px;
                  width: 250px;
                }

                 .leaflet-popup-content {
                 width: 300px !important;}
                 
                 .legend {
                 border-left:2px solid #666666;
                 border-right:2px solid #666666;
                 border-top:2px solid #666666;
                 border-bottom:2px solid #666666
                 }
                 
                 .highcharts-button-box {
                 stroke: #00008B;
                 stroke-width: 5;
                 fill: white;
                 }
                 '
      )),
    
    tabsetPanel(type = "tabs",
                
                tabPanel(div("Overview", style = "font-size: 16px;"),
                         
                         fluidRow(
                           
                           box(status = "danger", width = 12, 
                               
                               title = div("Provincial Population and Household Income per Capita", 
                                           style = "font-size:20px; font-weight: bold;"),
                               
                               tags$p("This interactive tool allows app users to
                                      examine and compare population and household income per 
                                      capita for each province or territory in Canada from 1999 to 2016.",
                                      br(), br(),
                                      "In the second tab (Map: Population and Household Income Growth in Canada), 
                                      select two years to see the change in population and household income by province/territory.
                                      Darker colours on the map represent higher rates of change in population and average income.",
                                      br(), br(),
                                      "In the third tab, population and household income per capita for 
                                      each province or territory are easily compared through the use of a treemap. 
                                      Rectangle size represents population, and colour represents income; 
                                      larger rectangles indicate larger populations 
                                      and darker colour indicates higher household income per capita.",
                                      style = "font-size:16px;")),
                           
                           )),
                
                tabPanel(div("Map: Population and Household Income Growth in Canada", style = "font-size: 16px;"),
                         
                         fluidRow(
                           
                           column(width = 2,
                                  
                                  box(width = NULL, status = "danger",
                                      
                                      div(selectInput(inputId = "YearInput", label = "Select Year",
                                                      
                                                      choices = unique(pop_income_data["Year"]),
                                                      
                                                      selected = unique(pop_income_data["Year"])[[1]][1]), style = "font-size: 17px;")),
                                      
                                  
                                  box(width = NULL, status = "danger",
                                      
                                      div(selectInput(inputId = "YearInput2", label = "Select Another Year",
                                                      
                                                      choices = unique(pop_income_data["Year"]),
                                                      
                                                      selected = unique(pop_income_data["Year"])[[1]][2]), style = "font-size: 17px;"),
                                      
                                  )
                           ),
                           column(width = 10,
                                  box(tags$p("Hover over a province/territory for more information.", br(),
                                             "Darker colours represent higher growth rates in population.", 
                                             
                                             style = "font-size:16px;"), width = NULL, status = "danger",
                                      
                                      solidHeader = FALSE, leafletOutput("map1", width = '100%')),
                                  
                                  box(title = tags$p("Hover over a province/territory for more information.", br(),
                                                     "Darker colours represent higher growth rates in household income per capita.",
                                                     
                                             style = "font-size:16px;"), width = NULL, status = "danger",
                                      
                                      solidHeader = FALSE, leafletOutput("map2", width = '100%'))
                           ))),
                
                
                tabPanel(div("Treemap: Comparing Population and Household Income in Canada", style = "font-size: 16px;"),
                         
                         fluidRow(
                           
                           column(width = 2,
                                  
                                  box(width = NULL, status = "danger",
                                      
                                      div(selectInput(inputId = "YearInput3", label = "Select Year",
                                                      
                                                      choices = unique(pop_income_data["Year"]),
                                                      
                                                      selected = unique(pop_income_data["Year"])[[1]][1]), style = "font-size: 17px;"))),
                           
                           column(width = 10,
                                  box(tags$p("Hover over a province/territory for more information.", br(),
                                             "Darker colours represent higher household income per capita and
                                             larger rectangles represent larger populations.", br(),
                                             "Scroll down to view the output data in table form.", 
                                             
                                             style = "font-size:16px;"), width = NULL, status = "danger",
                                      
                                      solidHeader = FALSE, highchartOutput("tree")),
                                  
                                  box(title = tags$p("Table: Output",
                                                     
                                                     style = "font-size:20px; font-weight: bold"), width = NULL, status = "primary",
                                      
                                      solidHeader = FALSE, div(DT::dataTableOutput("table"), style = "font-size: 15px;")))
                         )
                       )
  ))
)
