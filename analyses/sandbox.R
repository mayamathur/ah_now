
# Next up: Combine datasets from the different platforms and maybe try to populate the 
#  first set of cells?


root.path = "~/Dropbox/Personal computer/Independent studies/Animal Help Now/Analyses/ah_now_git"
setwd(root.path)

library(googleAnalyticsR)

root.path = "~/Dropbox/Personal computer/Independent studies/Animal Help Now/Analyses/ah_now_git"
setwd(root.path)


############################### HELPER FNS ############################### 

# pulls data as for google_analytics, but merged across the platforms
merge_platforms = function(start.date, end.date, ...){
  
  
  #browser()
  input_list <- as.list(substitute(list(...)))
  print(input_list)
  
  library(googleAnalyticsR)
  ga_auth()
  
  # make id-platform key
  ids = c(75070560, 66336346, 75085662, 66319754)
  platforms = c("iPhone", "web", "android", "mweb")
  
  datalist = lapply( 1:length(ids),
                     function(x) {
                       d.temp = google_analytics( ids[x], 
                        date_range = c(start.date, end.date),
                        metrics = c("ga:sessions"),
                        dimensions = c("ga:date",
                                                    "ga:eventCategory",
                                                    "ga:region",
                                                    "ga:country") )
                       
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
start.date = "2018-01-01"
end.date = "2018-06-01"


d = merge_platforms(start.date, end.date)


# sanity check
fake = d[d$platform=="iPhone" & d$eventCategory=="PhoneDialed",]
ids = c(75070560, 66336346, 75085662, 66319754)
platforms = c("iPhone", "web", "android", "mweb")
# look only at iPhone
fake = google_analytics( ids[3], 
                  date_range = c(start.date, end.date),
                  metrics = c("ga:sessions"),
                  dimensions = c("ga:date",
                                 "ga:eventCategory",
                                 "ga:region",
                                 "ga:country") )
( fake = fake[fake$eventCategory=="PhoneDialed",] )




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




# reproduce dashboard?
d4[d4$region=="colorado",]



# save the codebook
meta = google_analytics_meta()
write.csv(meta, "codebook.csv")



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



