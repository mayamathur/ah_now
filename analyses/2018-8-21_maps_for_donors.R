
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

d$type = d$caseflow_num

table(d$caseflow_num)
# ~~~ PROBLEM: RBINDLIST IS ADDING THE DECISIONNAVIGATION THING AGAIN

# ~~~ CHECK THESE WITH DAVE
# https://docs.google.com/spreadsheets/d/1-Zqk_HU_vIoLYeICdjtBDljCGrSt-9Tg_a53C2XrOsc/edit#gid=0
wildlife.nums = c(12:15, 17, 18, 201, 202 )
wildlife.emerg.nums = wildlife.nums[ !wildlife.nums == 202 ]
wildlife.conflict.nums = 202


############################### MAKE MAPS ###############################

##### Map 1: helper details or resources #####
chloropleth( .type = c( 201 ),
             .metric = "sessions",
             .platforms = c("iPhone", "web", "android", "mweb"),
             .start.date = "2018-01-01",
             .end.date = today(),
             .data=d, 
             .title = "YTD sessions displaying helper details or resources" )
