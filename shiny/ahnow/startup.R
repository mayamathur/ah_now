

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

# keeps original error messages
options(shiny.sanitize.errors = FALSE)


# download static data
# only needed if avoiding API data
# all data
#da = read.csv("2018-07-03_session_data.csv")

# read in types for use with dropdown menu
types = read.csv("list_of_types.csv")$x



############################### READ IN HELPER DATA ############################### 

#setwd("~/Dropbox/Personal computer/Independent studies/Animal Help Now/Analyses/ah_now_git/shiny/ahnow")
d = read.csv("helpers20180626.csv")

# recode missing data
d[ d == "null" ] = NA

library(dplyr)

# keep only 1 row/helper
f = d[ !duplicated(d$Name_Pub),]
f$latlon = paste( f$Latitude, ":", f$Longitude, sep="" )
f$latlon[f$latlon=="NA:NA"]=NA
