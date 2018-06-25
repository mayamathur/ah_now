
# Next up: Combine datasets from the different platforms and maybe try to populate the 
#  first set of cells?


root.path = "~/Dropbox/Personal computer/Independent studies/Animal Help Now/Analyses/ah_now_git"
setwd(root.path)

library(googleAnalyticsR)
library(dplyr)

root.path = "~/Dropbox/Personal computer/Independent studies/Animal Help Now/Analyses/ah_now_git"
setwd(root.path)

# save the codebook
meta = google_analytics_meta()
write.csv(meta, "ahnow_codebook.csv")


############################### HELPER FNS ############################### 

# pulls data as for google_analytics, but merged across the platforms
merge_platforms = function(start.date, end.date, ...){
  
  input_list <- as.list(substitute(list(...)))
  print(input_list)
  
  library(googleAnalyticsR)
  ga_auth()
  
  # make id-platform key
  # from viewID in: ga_account_list()
  ids = c(75070560, 66336346, 75085662, 66319754)
  platforms = c("iPhone", "web", "android", "mweb")
  
  datalist = lapply( 1:length(ids),
                     function(x) {
                       d.temp = google_analytics( ids[x], 
                        date_range = c(start.date, end.date),
                        metrics = c("ga:sessions"),
                        dimensions = c("ga:date",
                                      "ga:eventCategory",
                                       # "ga:eventAction",
                                      #"ga:eventLabel",
                                        "ga:region",
                                        "ga:country"),
                        max = -1 )  # -1 means to return all rows
                       
                       d.temp$viewID = ids[x]
                       d.temp$platform = platforms[x]
                       
                       return(d.temp)
                       }
                     )
  library(data.table)
  d = rbindlist(datalist)
  }


# ellipsis issue
# https://stackoverflow.com/questions/3057341/how-to-use-rs-ellipsis-feature-when-writing-your-own-function



############################### REPRODUCE ANALYSIS DASHBOARD ############################### 

# try to look at phone dials on iPhone

# # dates have to be specified like this
start.date = "2017-01-01"
end.date = "2017-12-31"


d = merge_platforms(start.date, end.date)



# sanity check
# iPhone
temp1 = google_analytics( 75070560,
                           date_range = c(start.date, end.date),
                           metrics = c("ga:sessions"),
                           dimensions = c("ga:date",
                                          "ga:eventCategory",
                                          "ga:region",
                                          "ga:country"),
                          max = -1 )

temp1 %>% filter( region == "Colorado" ) %>%
  group_by( eventCategory ) %>%
  summarise( total = sum(sessions) )

# Debugging Android -- basically 
# Android
temp2 = google_analytics( 75085662,
                          date_range = c(start.date, end.date),
                          metrics = c("ga:sessions"),
                          dimensions = c("ga:date",
                                         "ga:eventAction",
                                         "ga:region",
                                         "ga:country"),
                          max = -1 )

temp2 %>% filter( region == "Colorado" ) %>%
  group_by(eventAction) %>%
  summarise( total = sum(sessions) )




# same...
d %>% filter( eventCategory == "PhoneDialed", region == "Colorado" ) %>%
  group_by(platform) %>%
  summarise( total = sum(sessions) )
# 73

# HELPFUL - SUGGESTS THAT ANDROID HAS THE VARIABLES WITHIN DECISIONNAVIGATION
View( d %>% filter( region == "Colorado" ) %>%
  group_by(platform, eventCategory) %>%
  summarise( total = sum(sessions) ) )
# 73

# WAS CORRECT 73 BEFORE I ADDED THE TWO OTHER EVENT THINGS TO DIMENSIONS

# all sessions YTD
d %>% group_by(platform) %>%
  summarise( total = sum(sessions) )


############################### DEBUGGING ############################### 

# STILL UNRESOLVED
# why does querying additional dimensions change the results?

metric = "pageViews"
temp0 = google_analytics( 75070560,
                          date_range = c(start.date, end.date),
                          metrics = c(metric),
                          dimensions = c(
                                         "eventCategory"
                                         ),
                          max = -1 )

temp1 = google_analytics( 75070560,
                          date_range = c(start.date, end.date),
                          metrics = c(metric),
                          dimensions = c( 
                                        "eventAction",
                                         "eventCategory"
                                         ),
                          max = -1 )

# MATCHES
res0 = temp0 %>% 
  group_by( eventCategory ) %>%
  summarise( total = sum(pageView) )

# DOESN'T MATCH
res1 = temp1 %>%
  group_by( eventCategory ) %>%
  summarise( total = sum(pageViews) )

res1$total-res0$total

# sessions and users have discrepancy
# but pageViews doesn't


# with eventLabel: AnimalTypeFilter = 1996
# with eventLabel and eventAction: 1996
# with eventAction: 1996
# without: 1023
# with eventLabel and eventAction: 


############################### CALLS OVER TIME ############################### 

d$month = month(d$date)

( d.month = d %>% filter( country == "United States", eventCategory == "PhoneDialed" ) %>%
  group_by(month) %>%
  summarise( total = sum(sessions) ) )

# how are dates distributed?
library(lubridate)
table( month(d$date) )

library(ggplot2)

ggplot( data = d.month, aes(x = month, y = total) ) + 
  geom_line() +
  scale_x_continuous( breaks = seq(1, 12, 1)) +
  theme_classic()



############################### CHLOROPLETH ############################### 
# over last 12 months
# similar to their "in-between" metric of helpfulness

#event = "HelperDetail_Displayed"
event = "PhoneDialed"


# reshape to have 1 row per state
library(dplyr)

d2 = d %>% filter( country == "United States") %>%
        filter( eventCategory == event ) %>%
  group_by(region) %>%
  summarise( total = sum(sessions) )

d2$region = tolower(d2$region)



# make placeholder rows for nonexistent states
library(fiftystater)
state.names = unique( fifty_states$id )

d3 = data.frame( region = state.names, total = 0 )

d4 = merge( d3, d2, all.x = TRUE, by.x = "region", by.y = "region" )

names(d4)[ names(d4) == "total.y" ] = "total"
d4$total[ is.na(d4$total) ] = NA


# https://cran.r-project.org/web/packages/fiftystater/vignettes/fiftystater.html
library(ggplot2)


data("fifty_states") # this line is optional due to lazy data loading

library("RColorBrewer")
myPalette <- colorRampPalette(brewer.pal(50, "YlOrBr"))
sc <- scale_fill_gradientn(colours = myPalette(100), limits=c(0, max(d4$total, na.rm=TRUE)))

title = paste( "Frequency of phone dials (all platforms), ", start.date, " to ", end.date, sep="" )

# map_id creates the aesthetic mapping to the state name column in your data
p <- ggplot(d4, aes(map_id = region)) + 
  # map points to the fifty_states shape data
  geom_map(aes(fill = total), map = fifty_states) + 
  expand_limits(x = fifty_states$long, y = fifty_states$lat) +
  coord_map() +
  scale_fill_gradientn( colours = myPalette(100),
                       limits=c(0, max(d4$total) ),
                       na.value = "lightgray" ) +
  scale_x_continuous(breaks = NULL) + 
  scale_y_continuous(breaks = NULL) +
  labs(x = "", y = "") +
  theme(legend.position = "bottom", 
        panel.background = element_blank()) + 
  #guides(fill=guide_legend(title=" ")) +
  ggtitle(title)

p
# add border boxes to AK/HI
p + fifty_states_inset_boxes() 







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



