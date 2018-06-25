

# should pull new dataset from GA each time user changes start or end date, but not otherwise


############################### FN: SUMMARIZE EVENTS ############################### 

# to display the df in Shiny: 
# https://stackoverflow.com/questions/42665252/r-shiny-how-to-display-dataframe-in-shiny-app-using-shinydashboard-library

# uses the full date range represented by the dataset

summary_stats = function( .type, .metric = "sessions", .data ) {

  # totals by platform
  # https://stackoverflow.com/questions/26724124/standard-evaluation-in-dplyr-summarise-on-variable-given-as-a-character-string
  platform.tot = as.data.frame( .data[ .data$type == .type, ] %>%
                                  #filter( type == .type) %>%
                                  group_by(platform) %>%
                                  summarise( total = sum( !!sym(.metric) ) ) )
  
  # grand total across platforms
  grand.tot = as.numeric( .data[ .data$type == .type, ]  %>%
                            #filter( type == .type) %>%
                            summarise( total = sum( !!sym(.metric) ) ) )

  
  return( list( grand.tot = grand.tot, 
                platform.tot = platform.tot ) )
}



############################### FN: PULL DATA FOR CERTAIN PLATFORMS ############################### 

# pulls data as for google_analytics, but merged across the platforms
get_data = function( metric = "sessions",
                     start.date,
                     end.date ){
  #browser()
  
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
                       d.temp$month = month(d.temp$date)
                       
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


# d = get_data(metric = "sessions",
#                            start.date = "2017-01-01",
#                            end.date = "2017-12-01"  )
# 
# 
# x=1
# d = google_analytics( ids[x], 
#                   date_range = c("2017-01-01", "2017-12-01"),
#                   metrics = c("sessions"),
#                   dimensions = c( "date",
#                                   # ifelse thing is per Dashboard > Report Configuration
#                                   # ifelse( x == which( platforms == "android" ),
#                                   #         "eventAction",
#                                   #         "eventCategory" ),
#                                   "region",
#                                   "country"),
#                   max = -1 )

# ############################### FN: MAKE CHLOROPLETH ############################### 
# 
# 
# # make the plots interactive as in Corinne's code
# chloropleth = function( type,
#                         platforms = c("iPhone", "web", "android", "mweb"),
#                         start.date,
#                         end.date ) {
#   
#   event = "PhoneDialed"
#   
#   
#   # reshape to have 1 row per state
#   library(dplyr)
#   
#   d2 = d %>% filter( country == "United States") %>%
#     filter( type == event ) %>%
#     group_by(region) %>%
#     summarise( total = sum(sessions) )
#   
#   d2$region = tolower(d2$region)
#   
#   
#   
#   # make placeholder rows for nonexistent states
#   library(fiftystater)
#   state.names = unique( fifty_states$id )
#   
#   d3 = data.frame( region = state.names, total = 0 )
#   
#   d4 = merge( d3, d2, all.x = TRUE, by.x = "region", by.y = "region" )
#   
#   names(d4)[ names(d4) == "total.y" ] = "total"
#   d4$total[ is.na(d4$total) ] = NA
#   
#   
#   # https://cran.r-project.org/web/packages/fiftystater/vignettes/fiftystater.html
#   library(ggplot2)
#   
#   
#   data("fifty_states") # this line is optional due to lazy data loading
#   
#   library("RColorBrewer")
#   myPalette <- colorRampPalette(brewer.pal(50, "YlOrBr"))
#   sc <- scale_fill_gradientn(colours = myPalette(100), limits=c(0, max(d4$total, na.rm=TRUE)))
#   
#   title = paste( "Frequency of phone dials (all platforms), ", start.date, " to ", end.date, sep="" )
#   
#   # map_id creates the aesthetic mapping to the state name column in your data
#   p <- ggplot(d4, aes(map_id = region)) + 
#     # map points to the fifty_states shape data
#     geom_map(aes(fill = total), map = fifty_states) + 
#     expand_limits(x = fifty_states$long, y = fifty_states$lat) +
#     coord_map() +
#     scale_fill_gradientn( colours = myPalette(100),
#                           limits=c(0, max(d4$total) ),
#                           na.value = "lightgray" ) +
#     scale_x_continuous(breaks = NULL) + 
#     scale_y_continuous(breaks = NULL) +
#     labs(x = "", y = "") +
#     theme(legend.position = "bottom", 
#           panel.background = element_blank()) + 
#     #guides(fill=guide_legend(title=" ")) +
#     ggtitle(title)
#   
#   p
#   # add border boxes to AK/HI
#   p + fifty_states_inset_boxes() 
#   
# }
# 
# 
# ############################### FN: MAKE LINE PLOT OF EVENTS OVER TIME ############################### 
# 
# line_plot( platforms = c("iPhone", "web", "android", "mweb"),
#            start.date,
#            end.date ) {
#   
#   ( d.month = d %>% filter( country == "United States", eventCategory == "PhoneDialed" ) %>%
#       group_by(month) %>%
#       summarise( total = sum(sessions) ) )
#   
#   # how are dates distributed?
#   library(lubridate)
#   table( month(d$date) )
#   
#   library(ggplot2)
#   
#   ggplot( data = d.month, aes(x = month, y = total) ) + 
#     geom_line() +
#     scale_x_continuous( breaks = seq(1, 12, 1)) +
#     theme_classic()
#   
# }


############################### TEST ############################### 

# # try to look at phone dials on iPhone
# 
# # dates have to be specified like this
# start.date = "2017-01-01"
# end.date = "2017-12-31"
# 
# 
# d = get_data(start.date = start.date, end.date = end.date)
# 
# summary_stats( .type = "MapDirections", .metric = "sessions", .data = d )
# summary_stats( .type = "MapDirections", .metric = "sessions", .data = d )

