library(dplyr)
library(tidyr)

pop_can <- read.csv("pop_can.csv")
income_can <- read.csv("income_can.csv")

colnames(pop_can) # "ï..Geography" "X2012" "X2013" "X2014"  "X2015" "X2016" 

colnames(income_can) # "ï..Geography" "X2012" "X2013" "X2014"  "X2015" "X2016"

# Rename the columns to improve readability

colnames(pop_can) <- c("Region", "y2012", "y2013", "y2014", "y2015", "y2016")
colnames(income_can) <- c("Region", "y2012", "y2013", "y2014", "y2015", "y2016")

# Next, we need to convert the data frames from wide form to long form in order to 
#   create columns for year, population, and household income per capita 

l_pop_can <- reshape(pop_can, direction = "long",
                     varying = list(names(pop_can)[2:6]),
                     v.names = "Population", timevar = "Year", idvar = "Region",
                     times = 2012:2016, new.row.names = NULL)
rownames(l_pop_can) <- NULL

l_income_can <- reshape(income_can, direction = "long",
                        varying = list(names(income_can)[2:6]),
                        v.names = "Income", timevar = "Year", idvar = "Region",
                        times = 2012:2016, new.row.names = NULL)
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

# Remove rows with Region == "Canada" since we want to compare provinces/territories

final_data$Region <- as.character(final_data$Region)

final_data <- subset(final_data, Region != "Canada")

# Save final_data as .csv. Will be used in seperate server.R and ui.R files to make the Shinydashboard app

write.csv(x = final_data, file = "pop_income_data.csv", row.names = FALSE)