

############################### TRY TO GET WILDLIFE EMERGENCIES, ETC. ############################### 

setwd("~/Dropbox/Personal computer/Independent studies/Animal Help Now/Analyses/ah_now_git/shiny/ahnow")
source("functions.R")

library(googleAnalyticsR)

ids = c(75070560, 66336346, 75085662, 66319754)


#start.date = "2016-01-01"
start.date = "2018-01-01"
end.date = "2018-08-19"

# got segment info from: https://docs.google.com/spreadsheets/d/1YGx-eLl_yn4seYbbFmGg24etuAB9ltSDKeY9Av8iWeA/edit#gid=1684546460

# ## choose the v3 segment
# segment_for_call <- "gaid::3d0WmFriRf-O28_Q0nmCVg"
# 
# ## make the v3 segment object in the v4 segment object:
# seg_obj <- segment_ga4("my_segment_wildlife", segment_id = segment_for_call)

## make the segment call
iPhone = google_analytics( ids[3],
                          date_range = c(start.date, end.date),
                          metrics = c("ga:sessions"),
                          dimensions = c("ga:date",
                                         "ga:eventAction",
                                         "ga:eventCategory",
                                         #"ga:eventLabel",
                                         #"ga:pagePath",
                                         #"ga:referralPath",
                                         #"ga:pageTitle",
                                         #"ga:userDefinedValue",
                                         "ga:region",
                                         "ga:country"),
                          max = -1 )
                          #segments = seg_obj )

#unique(iPhone$eventLabel[ iPhone$eventCategory == "CaseFlow"])
# BINGO

unique(iPhone$eventAction[ iPhone$eventCategory == "CaseFlow"])


# event actions corresponding to wildlife things
unique( iPhone$eventAction[ iPhone$eventLabel %in% wildlife.labels ] )


library(varhandle)
unique(iPhone$eventAction)

unique( iPhone$eventAction[ check.numeric(iPhone$eventAction) ] )


# list the wildlife ones
wildlife.labels = unique( iPhone$eventLabel[ grep("wildlife", iPhone$eventLabel) ])

# filter to the ones with "wildlife" somewhere in the title
temp = iPhone[ iPhone$eventCategory == "CaseFlow" &
                 iPhone$eventLabel %in% wildlife.labels, ]


# BOOKMARK: CHECK WHETHER IPHONE DATASET HAS EXPECTED NUMBER OF SESSIONS

# 
# and = google_analytics( ids[3],
#                            date_range = c(start.date, end.date),
#                            metrics = c("ga:sessions"),
#                            dimensions = c("ga:date",
#                                           "ga:eventAction",
#                                           "ga:eventCategory",
#                                           "ga:region",
#                                           "ga:country") )


unique(d$eventCategory)

# THIS LISTS THE PATH NUMBER
unique(iPhone$eventAction[ iPhone$eventCategory == "CaseFlow"])

# Android
unique(and$eventAction[ and$eventCategory == "DecisionNavigation"])



############################### HELPER FNS ############################### 
# Next up: Shiny functions

# pull new dataset from GA each time user changes start or end date, but not otherwise

get_data = function( metric = "sessions", start.date, end.date ) {
  
}

summary_stats = function( type, data ) {
  
  # grand total of metric for this type (e.g., PhoneDialed)
  
  # table of metric total by platform 
}

# make the plots interactive as in Corinne's code
chloropleth = function( type,
                        platforms = c("iPhone", "web", "android", "mweb"),
                        start.date,
                        end.date ) {
  
}

line_plot( platforms = c("iPhone", "web", "android", "mweb"),
           start.date,
           end.date ) {
  
}


############################### SETUP ############################### 


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

library(googleAnalyticsR)
ga_auth()

# pulls data as for google_analytics, but merged across the platforms
merge_platforms = function(metric = "sessions", start.date, end.date, ...){
  
  input_list <- as.list(substitute(list(...)))
  print(input_list)
  
  # make id-platform key
  # from viewID in: ga_account_list()
  ids = c(75070560, 66336346, 75085662, 66319754)
  platforms = c("iPhone", "web", "android", "mweb")

  datalist = lapply( 1:length(ids),
                     function(x) {
                       d.temp = google_analytics( ids[x], 
                        date_range = c(start.date, end.date),
                        metrics = c(metric),
                        dimensions = c( "date",
                                      # ifelse thing is per Dashboard > Report Configuration
                                      ifelse( x == which( platforms == "android" ),
                                              "eventAction",
                                              "eventCategory" ),
                                      "region",
                                      "country"),
                        max = -1 )  # -1 means to return all rows
                       
                       # merge info on which platform and ID we pulled
                       d.temp$viewID = ids[x]
                       d.temp$platform = platforms[x]
                       
                       
                       # to allow happy merging
                       if ( x == which( platforms == "android" ) ) {
                         names(d.temp)[ names(d.temp) == "eventAction" ] = "type" 
                       } else {
                         names(d.temp)[ names(d.temp) == "eventCategory" ] = "type"
                       }
                       
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


d = merge_platforms(start.date = start.date, end.date = end.date)



# # sanity check
# # iPhone
# temp1 = google_analytics( 75070560,
#                            date_range = c(start.date, end.date),
#                            metrics = c("ga:sessions"),
#                            dimensions = c("ga:date",
#                                           "ga:eventCategory",
#                                           "ga:region",
#                                           "ga:country"),
#                           max = -1 )
# 
# temp1 %>% filter( region == "Colorado" ) %>%
#   group_by( eventCategory ) %>%
#   summarise( total = sum(sessions) )
# 
# # Debugging Android -- basically
# # Android
# temp2 = google_analytics( 75085662,
#                           date_range = c(start.date, end.date),
#                           metrics = c("ga:sessions"),
#                           dimensions = c("ga:date",
#                                          "ga:eventAction",
#                                          "ga:region",
#                                          "ga:country"),
#                           max = -1 )
# 
# temp2 %>% filter( region == "Colorado" ) %>%
#   group_by(eventAction) %>%
#   summarise( total = sum(sessions) )



# YESSSSSS! MATCHES!!!
# same...
View( d %>% filter( region == "Colorado" ) %>%
  group_by(platform, type) %>%
  summarise( total = sum(sessions) ) )

# all sessions YTD
d %>% group_by(platform) %>%
  summarise( total = sum(sessions) )


############################### DEBUGGING ############################### 


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
        filter( type == event ) %>%
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



