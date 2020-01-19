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

dashboardPage(
  
  skin = "purple",
  
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
                 
                 "),
      
      tags$style('
                 
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
                           
                           box(status = "primary", width = 12, 
                               
                               title = div("Title", 
                                           style = "font-size:20px; font-weight: bold;"),
                               
                               tags$p("This interactive tool allows users to
                                      examine the population and household income per 
                                      capita for each province/territory from 2012 to 2016.",
                                      br(), br(),
                                      "The population and household income per capita for each province/territory 
                                      are easily compared through the use of a treemap. Rectangle size represents 
                                      population, and colour represents income; larger rectangles indicate larger populations 
                                      and darker colour indicates higher household income per capita.", 
                                      
                                      style = "font-size:16px;")),
                           
                           )),
                
                tabPanel(div("Treemap: Population and Household Income per Capita in Canada", style = "font-size: 16px;"),
                         
                         fluidRow(
                           
                           column(width = 2,
                                  
                                  box(width = NULL, status = "primary",
                                      div(selectInput(inputId = "YearInput", label = "Select Year",
                                                      
                                                      choices = c("2012", "2013", "2014", 
                                                                  "2015", "2016")), style = "font-size: 16px;"))),
                           
                           column(width = 10,
                                  box(tags$p("Hover over a province/territory for more information.", br(),
                                             "Darker colours represent higher household income per capita and
                                             larger rectangles represent larger populations.", 
                                             
                                             style = "font-size:16px;"), width = NULL, status = "primary",
                                      
                                      solidHeader = FALSE, highchartOutput("tree")),
                                  
                                  box(title = tags$p("Table: Output",
                                                     
                                                     style = "font-size:20px; font-weight: bold"), width = NULL, status = "primary",
                                      
                                      solidHeader = FALSE, div(DT::dataTableOutput("table"), style = "font-size: 15px;")))
                         )
                       )
  ))
)