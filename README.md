# RShiny-Treemap

This is an R Shiny app that visualizes population and household income per capita for Canada's thirteen provinces and territories in an interactive dashboard. 

The data used in the app comes from Statistics Canada 'Table 36-10-0229-01 Long-run provincial and territorial data' (https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3610022901) and consists of estimates of economic variables including population and average household income in Canada from 1999 to 2016.

The population and household income per capita for each province/territory are easily compared through the use of a treemap. Rectangle size represents population, and colour represents income; larger rectangles indicate larger populations and darker colour indicates higher household income per capita. Tooltips allow users of the app to quickly see both of these values for each province/territory.

The datasets, code for the server and ui files, and the code used for data cleaning can be found in the repository.
