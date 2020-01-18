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

l_pop_can <- gather(pop_can, year, population, y2012:y2016, factor_key = TRUE)
colnames(l_pop_can) # "Region" "year" "population"

l_income_can <- gather(income_can, year, income, y2012:y2016, factor_key = TRUE)
colnames(l_income_can) # "Region" "year" "income"

# In the population and income per capita columns, values contain commas; these need to be removed.
#   Use the 'gsub' function to do this

l_income_can$income <- gsub(",", "", l_income_can$income)
l_pop_can$population <- gsub(",", "", l_pop_can$population)

l_income_can$income <- as.numeric(l_income_can$income) # Change from character to number
l_pop_can$population <- as.numeric(l_pop_can$population) # Change from character to number

# Now we can merge the income and population data sets by region and year

final_data <- merge(l_pop_can, l_income_can, by = c("Region", "year"))

# Create column for region type (Canada as a whole or province/territory)

final_data$RegionType <- rep(NA, nrow(final_data))

for (i in 1:nrow(final_data)){
  if (final_data$Region[i] == "Canada"){
    final_data$RegionType[i] <- "Country"}
  else {final_data$RegionType[i] <- "ProvTerr"}
}

# Multiply population column by 1000

final_data$population <- final_data$population*1000

typeof(final_data$Region) # "integer"
final_data$Region <- as.character(final_data$Region)
typeof(final_data$Region) # "character"

typeof(final_data$year) # "integer"
final_data$year <- as.character(final_data$year)
typeof(final_data$year) # "character"

typeof(final_data$population) # "double"

typeof(final_data$income) # "double"

typeof(final_data$RegionType) # "character"

# Save final_data as .csv. Will be used in seperate server.R and ui.R files to make the Shinydashboard app

write.csv(x = final_data, file = "pop_income_data.csv", row.names = FALSE)