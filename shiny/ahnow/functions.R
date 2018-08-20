
# TO DO: 
#  make password work
#  have checkboxes to include only certain platforms in heat map and line plot


# make list of types (metrics)
# setwd("~/Dropbox/Personal computer/Independent studies/Animal Help Now/Analyses/ah_now_git/shiny/ahnow")
# d = read.csv("2018-07-03_session_data.csv")
# types = as.character( sort( unique(d$type) ) )
# types = collapse( types, ",")
# write.csv(types, "list_of_types.csv")

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

# d = get_data( start.date = "2017-01-01", end.date = "2017-12-31")
# stats = summary_stats( .type = "PhoneDialed", .metric = "sessions", .data = d )

############################### FN: PULL DATA FOR CERTAIN PLATFORMS ############################### 

# MAINLY FOR DEBUGGING (AVOID API CALL)

# get_data_no_API = function( metric = "sessions",
#                             start.date,
#                             end.date,
#                             region = NA ){
#   
#   # # check if we have the global variable for the dataset
#   # if( !exists("da") ) {
#   #   setwd("~/Dropbox/Personal computer/Independent studies/Animal Help Now/Analyses/ah_now_git/shiny/ahnow")
#   #   da = read.csv("2018-07-03_session_data.csv")
#   # }
#   # 
#   # da = da[ , names(da) != "X" ]
#   
#   d = da[ as.Date(da$date) >= format( start.date ) &
#                as.Date(da$date) <= format( end.date ) &
#                tolower(da$region) == region, ]
#   
#   
#   # 
#   # d = da %>% filter( as.Date(date) >= format(start.date) &
#   #                      as.Date(date) <= format(end.date) )
#   # 
#   # if ( !is.na(region) ) {
#   #   d = d %>% filter( tolower(region) == region )
#   # }
#   # 
#   return(d)
# }


# d2 = get_data_no_API(metric = "sessions",
#                      start.date = "2017-01-01",
#                      end.date = "2017-12-01"  )
# 
# d2 = get_data_no_API(metric = "sessions",
#                      start.date = "2017-01-01",
#                      end.date = "2017-12-01",
#                      region = "colorado" )




# pulls data as for google_analytics, but merged across the platforms
get_data = function( metric = "sessions",
                     start.date,
                     end.date,
                     region = NA,
                     .platforms = c("iPhone", "android", "mweb", "web"),
                     paths = FALSE ){

  # make id-platform key
  # from viewID in: ga_account_list()
  ids = c(75070560, 66336346, 75085662, 66319754)
  platforms = c("iPhone", "web", "android", "mweb")
  
  # if not using all platforms
  if( length( .platforms ) < 4 ) {
    ids = ids[ platforms %in% .platforms ]
    platforms = platforms[ platforms %in% .platforms ]
  }
  
  datalist = lapply( 1:length(ids),
                     function(x) {
                       d.temp = fetch_one_platform( metric = metric, 
                                                    start.date = start.date,
                                                    end.date = end.date,
                                                    platform = platforms[x],
                                                    id = ids[x],
                                                    paths = paths )
                     }
                    )
  
  library(data.table)
  d = rbindlist(datalist)
  
  # subset to specified region if needed
  if (! is.na(region) ) {
    # doesn't work for mysterious reasons
   # d = d[ tolower(d$region) == region, ]
    
    ind = tolower(d$region) == region
    d = d[ind,]
  }
  
  return(d)
}


fetch_one_platform = function( metric,
                               start.date,
                               end.date,
                               platform,
                               id,
                               paths = FALSE ) {
  
  
  ##### Non-Path Data #####
  # if not interested in path data, then just query the needed dimension
  #  based on platform
  if ( paths == FALSE ) {
    # ifelse thing is per Dashboard > Report Configuration
    if (platform == "android") {
      event.dim = "eventAction"
    } else {
      event.dim = "eventCategory"
    }
    
    d.temp = google_analytics( id, 
                               date_range = c( format(start.date), format(end.date) ),
                               metrics = c(metric),
                               dimensions = c( "date",
                                               event.dim,
                                               "region",
                                               "longitude",
                                               "latitude",
                                               "country"),
                               max = -1 )  # -1 means to return all rows
    
    # to allow happy merging
    if (platform == "android") {
      names(d.temp)[ names(d.temp) == "eventAction" ] = "type" 
    } else {
      names(d.temp)[ names(d.temp) == "eventCategory" ] = "type"
    }
  }
  
  ##### Path Data #####
  # if interested in paths data, then need both eventAction and eventCategory per
  #  platform because of differences in data collection across platforms 
  if ( paths == TRUE ) {
    # get data for this platform
    d.temp = google_analytics( id, 
                               date_range = c( format(start.date), format(end.date) ),
                               metrics = c(metric),
                               dimensions = c( "date",
                                               "eventAction",
                                               "eventCategory",
                                               "eventLabel",
                                               "region",
                                               "longitude",
                                               "latitude",
                                               "country"),
                               max = -1 )  # -1 means to return all rows
    
    # to allow happy merging
    if (platform == "android") {
      # the CaseFlow codes corresponding to those recorded by other platforms are
      #  buried in the eventLabels
      keeper.codes = unique(d.temp$eventLabel)[ grep( "Case Flow", unique(d.temp$eventLabel) ) ]
      
      d.temp = d.temp[ d.temp$eventLabel %in% keeper.codes, ]
      
      # sync the variable names across platforms
      names(d.temp)[ names(d.temp) == "eventLabel" ] = "caseflow_num"
      
      # sync the variable content across platforms
      # Android has the number embedded in a string
      library(stringr)
      d.temp$caseflow_num = as.numeric( str_extract( d.temp$caseflow_num, "[[:digit:]]+" ) )
      
      # for happy merging
      d.temp = d.temp[ , !names(d.temp) == "eventAction" ]
      
    } else {
      # keep only CaseFlow information (the ones with paths)
      d.temp = d.temp[ d.temp$eventCategory == "CaseFlow", ]
      
      # sync the variable names across platforms
      names(d.temp)[ names(d.temp) == "eventAction" ] = "caseflow_num"
      
      # sync the variable content across platforms
      d.temp$caseflow_num = as.numeric( d.temp$caseflow_num )
      
      # for happy merging
      d.temp = d.temp[ , !names(d.temp) == "eventLabel" ]

    }
    
  }
  
  if( is.null(d.temp) ) stop("No data available for those choices of parameters.")
  
  # merge info on which platform and ID we pulled
  d.temp$viewID = id
  d.temp$platform = platform
  d.temp$month = month(d.temp$date)
  
  
  return(d.temp)
}





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

############################### FN: MAKE CHLOROPLETH ###############################

# .type can be a vector to consider events in multiple categories
# .title: title for plot

chloropleth = function( .type,
                        .metric,
                        .platforms = c("iPhone", "web", "android", "mweb"),
                        .start.date,
                        .end.date,
                        .data,
                        .title = NA ) {
  
  # reshape to have 1 row per state
  d2 = .data[ .data$type %in% .type & .data$platform %in% .platforms, ] %>%
    filter( country == "United States") %>%
    group_by(region) %>%
    summarise( total = sum( !!sym(.metric) ) )

  d2$region = tolower(d2$region)


  # https://cran.r-project.org/web/packages/fiftystater/vignettes/fiftystater.html
  # make placeholder rows for nonexistent states
  state.names = unique( fifty_states$id )

  d3 = data.frame( region = state.names, total = 0 )

  d4 = merge( d3, d2, all.x = TRUE, by.x = "region", by.y = "region" )

  names(d4)[ names(d4) == "total.y" ] = "total"
  d4$total[ is.na(d4$total) ] = NA


  library("RColorBrewer")
  myPalette = colorRampPalette(brewer.pal(9, "YlOrBr"))
  #sc = scale_fill_gradientn(colours = myPalette(100), limits=c(0, max(d4$total, na.rm=TRUE)))

  if ( is.na(.title) ) {
    title = paste( "Total ", .metric, " of ",
                   paste( .type, collapse=" + "), # collapse to handle when .type has length > 1
                   ", ",
                   .start.date, " to ",
                   .end.date, sep="" )
  } else {
    title = .title
  }
  
  
  # calculate breaks for legend
  # even jumps from 0 to max number displayed in plot
  max = max(d4$total, na.rm=TRUE)
  breaks = seq( 0, max, length.out = 5 )
  
  # round to nearest 100, 10, or 1 depending on how big the numbers are
  if ( max > 1000 ) {
    breaks = round( breaks / 100 ) * 100
  } else if ( max > 100 ) {
    breaks = round( breaks / 10 ) * 10
  } else {
      breaks = round( breaks )
  }
  
  
  # map_id creates the aesthetic mapping to the state name column in your data
  p <- ggplot(d4, aes(map_id = region)) +
    # map points to the fifty_states shape data
    geom_map(aes(fill = total), map = fifty_states) +
    expand_limits(x = fifty_states$long, y = fifty_states$lat) +
    coord_map() +
    scale_fill_gradientn( colours = myPalette(100),
                          limits=c(0, max ),
                          breaks = breaks,
                          na.value = "lightgray" ) +
    scale_x_continuous(breaks = NULL) +
    scale_y_continuous(breaks = NULL) +
    labs(x = "", y = "") +
    # note that one of these things in theme() removes the heatmap legend
    theme(legend.position = "bottom",
          panel.background = element_blank(),
          axis.line=element_blank(),
          axis.text.x=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks=element_blank(),
          axis.title.x=element_blank(),
          axis.title.y=element_blank()
          ) +
    guides(fill=guide_legend(title=" ")) +
    ggtitle(title)

  # add border boxes to AK/HI
  p + fifty_states_inset_boxes()

}


# d = get_data(metric = "sessions",
#                            start.date = "2017-01-01",
#                            end.date = "2017-12-01"  )
# 
# chloropleth( .type = c( "HelperDetail_Displayed", "Resources" ),
#                         .metric = "sessions",
#                         .platforms = c("iPhone", "web", "android", "mweb"),
#                         .start.date = "2017-01-01",
#                         .end.date = "2017-12-31",
#                         .data=d )



############################### FN: MAKE LINE PLOT OF EVENTS OVER TIME ###############################

line_plot = function( .data,
           .type,
           .metric,
            .platforms = c("iPhone", "web", "android", "mweb"),
           .start.date,
           .end.date ) {

  d.month = .data[ .data$type == .type & .data$platform %in% .platforms, ] %>% filter( country == "United States" ) %>%
      group_by(month) %>%
      summarise( total = sum( !!sym(.metric) ) )

  ggplot( data = d.month, aes(x = month, y = total) ) +
    geom_line() +
    scale_x_continuous( breaks = seq(1, 12, 1) ) +
    theme_classic()
}


# line_plot( .type = "PhoneDialed",
#                         .metric = "sessions",
#                         .platforms = c("iPhone", "web", "android", "mweb"),
#                         .start.date = "2017-01-01",
#                         .end.date = "2017-11-31",
#                         .data=d )

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


