# R-Shiny-Dashboard-Canada

Please visit [here](https://christianarkoebel.shinyapps.io/Shiny-Dashboard-Canada/?_ga=2.225870738.92068859.1602961760-1069993223.1602275863) to explore the Shinydashboard.

This is an R Shiny app that visualizes population and household income per capita for Canada's thirteen provinces and territories from 1999 to 2016 in an interactive dashboard. 

The data used in the app comes from Statistics Canada 'Table 36-10-0229-01 Long-run provincial and territorial data' (https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3610022901) and consists of estimates of economic variables including population and average household income in Canada from 1999 to 2016.

In the tab on the dashboard entitled, "Map: Population and Household Income Growth in Canada", select two years between 1999 and 2016 to see the change in population and household income by province/territory. Darker colours on the map represent higher growth rates in population and average household income.

Furthermore, the population and household income per capita for each province/territory can be easily compared through the use of a treemap in the third tab entitled, "Treemap: Comparing Population and Household Income in Canada". Rectangle size represents population, and colour represents income; larger rectangles indicate larger populations and darker colour indicates higher household income per capita. Tooltips allow users of the app to quickly see both of these values for each province/territory.

The datasets, code for the server and ui files, and the code used for data cleaning can be found in the repository.
