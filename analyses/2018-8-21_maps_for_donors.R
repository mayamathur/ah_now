
############################### SET UP ############################### 


library(googleAnalyticsR)
library(dplyr)
library(rlang)
library(lubridate)
library(plotly)
library(fiftystater)
library(ggplot2)
library(mapproj)
library(shinycssloaders)  # for loading spinners
library(googleVis)

library(maps) # for helper map
library(mapdata) # for helper map

# https://github.com/MarkEdmondson1234/googleAnalyticsR/issues/126
ga_auth(".httr-oauth")


setwd("~/Dropbox/Personal computer/Independent studies/Animal Help Now/Analyses/ah_now_git/shiny/ahnow")
source("functions.R")


############################### GET YTD DATA ############################### 

d = get_data(metric = "sessions",
             start.date = "2018-01-01",
             end.date = today() )


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
iPhone = google_analytics( ids[1],
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





and = google_analytics( ids[3],
                           date_range = c(start.date, end.date),
                           metrics = c("ga:sessions"),
                           dimensions = c("ga:date",
                                          "ga:eventAction",
                                          "ga:eventCategory",
                                          "ga:eventLabel",
                                          "ga:region",
                                          "ga:country"),
                           max = -1 )
#segments = seg_obj )




##### sync up the event numbers across platforms #####

# CASE FLOW NUMBERS FOR IPHONE
unique(iPhone$eventAction[ iPhone$eventCategory == "CaseFlow"])

# THESE CORRESPOND TO THE IPHONE EVENT ACTIONS!!!
keeper.codes = unique(and$eventLabel)[ grep( "Case Flow", unique(and$eventLabel) ) ]

# subset to case flow data in each platform
and = and[ and$eventLabel %in% keeper.codes, ]
iPhone = iPhone[ iPhone$eventCategory == "CaseFlow", ]

# sync the variable names
names(and)[ names(and) == "eventLabel" ] = "caseflow_num"
names(iPhone)[ names(iPhone) == "eventAction" ] = "caseflow_num"

# sync the variable content
# Android has the number embedded in a string
library(stringr)
and$caseflow_num = as.numeric( str_extract( and$caseflow_num, "[[:digit:]]+" ) )
iPhone$caseflow_num = as.numeric( iPhone$caseflow_num )

# 
#and = and[ !and$caseflow_num ]

# merge them
 and = and[ , !names(and) == "eventAction" ] # for happy merging
# datalist = list( iPhone, and )
# library(data.table)
# d = rbindlist(datalist)  # DOESN'T WORK. ADDS A WEIRD LEVEL TO CASEFLOW_NUM. 
 
 d = rbind(iPhone, and)
 
 
 
 
 ############################### GET PATH DATA FOR ALL PLATFORMS ############################### 
 
 
 
 fetch_one_platform = function( metric,
                                start.date,
                                end.date,
                                platform,
                                id,
                                paths = FALSE ) {
   
   # TESTING ONLY
   
   
   ##### Non-Path Data #####
   # if not interested in path data, then just query the needed dimension
   #  based on platform
   if ( paths = FALSE ) {
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
   if ( paths = TRUE ) {
     # get data for this platform
     d.temp = google_analytics( id, 
                                date_range = c( format(start.date), format(end.date) ),
                                metrics = c(metric),
                                dimensions = c( "date",
                                                "eventAction",
                                                "eventCategory",
                                                "region",
                                                "longitude",
                                                "latitude",
                                                "country"),
                                max = -1 )  # -1 means to return all rows
     
     # to allow happy merging
     if (platform == "android") {
       # the CaseFlow codes corresponding to those recorded by other platforms are
       #  buried in the eventLabels
       keeper.codes = unique(and$eventLabel)[ grep( "Case Flow", unique(and$eventLabel) ) ]
       
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
       names(iPhone)[ names(iPhone) == "eventAction" ] = "caseflow_num"
       
       # sync the variable content across platforms
       iPhone$caseflow_num = as.numeric( iPhone$caseflow_num )
     }
    
   }
   
   if( is.null(d.temp) ) stop("No data available for those choices of parameters.")
   
   # merge info on which platform and ID we pulled
   d.temp$viewID = id
   d.temp$platform = platform
   d.temp$month = month(d.temp$date)
   

   return(d.temp)
 }


############################### MAKE MAPS ###############################

##### Map 1: helper details or resources #####
chloropleth( .type = c( "HelperDetail_Displayed", "Resources" ),
             .metric = "sessions",
             .platforms = c("iPhone", "web", "android", "mweb"),
             .start.date = "2018-01-01",
             .end.date = today(),
             .data=d, 
             .title = "YTD sessions displaying helper details or resources" )

setwd("~/Dropbox/Personal computer/Independent studies/Animal Help Now/Analyses/ah_now_git/for_dave/2018-8-19")
width = 8
# square.size = 8/3 # divide by number of cols
# height = square.size*5  # multiply by number of rows
ggsave( filename = "donor_map1.png",
        path=NULL, width=width, units="in")


##### Map 2: just resources #####

chloropleth( .type = c( "Resources" ),
             .metric = "sessions",
             .platforms = c("iPhone", "web", "android", "mweb"),
             .start.date = "2018-01-01",
             .end.date = today(),
             .data=d, 
             .title = "YTD sessions displaying resources" )

setwd("~/Dropbox/Personal computer/Independent studies/Animal Help Now/Analyses/ah_now_git/for_dave/2018-8-19")
width = 8
# square.size = 8/3 # divide by number of cols
# height = square.size*5  # multiply by number of rows
ggsave( filename = "donor_map2.png",
        path=NULL, width=width, units="in")
