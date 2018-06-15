
############################### PACKAGE #1 ############################### 

root.path = "~/Dropbox/Personal computer/Independent studies/Animal Help Now/Analyses/ah_now_git"
setwd(root.path)

library(googleAnalyticsR)

# http://www.ryanpraski.com/google-analytics-r-tutorial/
# https://www.lunametrics.com/blog/2015/11/23/export-google-analytics-data-with-r/

# list of other packages for GA:
# http://code.markedmondson.me/googleAnalyticsR/index.html

#Authorize Google Analytics R- this will open a webpage
#You must be logged into your Google Analytics account on your web browser
ga_auth()

#Use the Google Analytics Management API to see a list of Google Analytics accounts you have access to
( my_accounts <- google_analytics_account_list() )

#Use my_accounts to find the viewId (NOT THE OTHER IDS). Make sure to replace this with your viewId.
# different viewIds for each platform; this is the iPhone app
my_id <- 75070560

#set date variables for dyanmic date range
start.date <- "60daysAgo"
end.date <- "yesterday"


# show the variables
allowed_metric_dim( type = "METRIC" )
allowed_metric_dim( type = "DIMENSION" )

# save the codebook
meta = google_analytics_meta()
write.csv(meta, "codebook.csv")

#Page View Query
d <- google_analytics(my_id, 
                          date_range = c(start.date, end.date),
                          metrics = c("ga:sessions"),
                          dimensions = c("ga:date"))

#graph sessions by date
library(ggplot2)
ggplot(data=d, aes(x=date, y=sessions)) +
  geom_line(stat="identity")


############################### REPRODUCE ANALYSIS DASHBOARD ############################### 

# try to look at phone dials on iPhone

# dates have to be specified like this
start.date = "2018-01-01"
end.date = "2018-06-01"

d <- google_analytics(my_id, 
                      date_range = c(start.date, end.date),
                      metrics = c("ga:sessions"),
                      dimensions = c("ga:date",
                                     "ga:eventCategory",
                                     "ga:region",
                                     "ga:country") )

table(d$eventCategory)
# ah-ha! so the HelperDetail_Displayed, etc., are various values for the eventCategory



############################### IPHONE HELPER DETAILS DISPLAYED CHLOROPLETH ############################### 

# similar to their "in-between" metric of helpfulness

d2 = d[ d$country == "United States" &
             d$eventCategory == "HelperDetail_Displayed", ]

# reshape to have 1 row per state
library(dplyr)

d2 = d %>% filter( country == "United States") %>%
        filter( eventCategory == "HelperDetail_Displayed" ) %>%
  group_by(region) %>%
  summarise( total = sum(sessions) )

d2$region = tolower(d2$region)

# make placeholder rows for nonexistent states
state.names = unique( fifty_states$id )

d3 = data.frame( region = state.names, total = 0 )

d4 = merge( d3, d2, all.x = TRUE, by.x = "region", by.y = "region" )

names(d4)[ names(d4) == "total.y" ] = "total"
d4$total[ is.na(d4$total) ] = 0



# https://cran.r-project.org/web/packages/fiftystater/vignettes/fiftystater.html
library(ggplot2)
library(fiftystater)

data("fifty_states") # this line is optional due to lazy data loading

# map_id creates the aesthetic mapping to the state name column in your data
p <- ggplot(d4, aes(map_id = region)) + 
  # map points to the fifty_states shape data
  geom_map(aes(fill = total), map = fifty_states) + 
  expand_limits(x = fifty_states$long, y = fifty_states$lat) +
  coord_map() +
  #scale_fill_hue(name="Value") +
  scale_x_continuous(breaks = NULL) + 
  scale_y_continuous(breaks = NULL) +
  labs(x = "", y = "") +
  theme(legend.position = "bottom", 
        panel.background = element_blank())

p
# add border boxes to AK/HI
p + fifty_states_inset_boxes() 


