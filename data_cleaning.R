library(dplyr)
library(tidyr)
library(openxlsx)

pop_can <- read.xlsx("pop.xlsx")
income_can <- read.xlsx("inc.xlsx")

colnames(pop_can)[1] <- "Region" 

colnames(income_can)[1] <- "Region"

# Next, we need to convert the data frames from wide form to long form in order to 
#   create columns for year, population, and household income per capita 

l_pop_can <- reshape(pop_can, direction = "long",
                     varying = list(names(pop_can)[2:19]),
                     v.names = "Population", timevar = "Year", idvar = "Region",
                     times = 1999:2016, new.row.names = NULL)

rownames(l_pop_can) <- NULL

l_income_can <- reshape(income_can, direction = "long",
                        varying = list(names(income_can)[2:19]),
                        v.names = "Income", timevar = "Year", idvar = "Region",
                        times = 1999:2016, new.row.names = NULL)

rownames(l_income_can) <- NULL

# In the population and income per capita columns, values contain commas; these need to be removed.
#   Use the 'gsub' function to do this

l_income_can$Income <- gsub(",", "", l_income_can$Income)
l_pop_can$Population <- gsub(",", "", l_pop_can$Population)

# Now we can merge the income and population data sets by region and year

final_data <- merge(l_pop_can, l_income_can, by = c("Region", "Year"))

# Multiply population column by 1000

final_data$Population <- as.numeric(final_data$Population)

final_data$Population <- final_data$Population*1000

# Remove rows with Region == "Canada" since we only want to compare provinces/territories

final_data$Region <- as.character(final_data$Region)

final_data <- subset(final_data, Region != "Canada")

# Save final_data as .csv. Will be used in separate server.R and ui.R files to make the Shinydashboard app

write.csv(x = final_data, file = "pop_income_data.csv", row.names = FALSE)

pop_income_data <- read.csv(file = "pop_income_data.csv")
