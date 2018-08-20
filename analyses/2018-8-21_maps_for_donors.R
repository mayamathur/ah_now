
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


############################### GET YTD PATH DATA FOR ALL PLATFORMS ############################### 

d = get_data(metric = "sessions",
             start.date = "2018-01-01",
             end.date = today(),
             paths = TRUE )



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
