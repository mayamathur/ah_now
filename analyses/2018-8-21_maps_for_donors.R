
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

# resources data (not paths)
dr = get_data(metric = "sessions",
              start.date = "2018-01-01",
              end.date = today(),
              paths = FALSE )


# paths data
dp = get_data(metric = "sessions",
             start.date = "2018-01-01",
             end.date = today(),
             paths = TRUE )



# rename to play well with chloropleth fn.
dp$type = dp$caseflow_num

table(dp$caseflow_num)

# https://docs.google.com/spreadsheets/d/1-Zqk_HU_vIoLYeICdjtBDljCGrSt-9Tg_a53C2XrOsc/edit#gid=0
all.nums = unique(dp$caseflow_num)[ !is.na( unique(dp$caseflow_num) ) ]
wildlife.nums = c(12:15, 17, 18, 201, 202 )
wildlife.emerg.nums = wildlife.nums[ !wildlife.nums == 202 ]
wildlife.conflict.nums = 202


# manual sanity check
agg = dp %>% group_by(region) %>%
  filter(caseflow_num %in% wildlife.emerg.nums ) %>%
  filter(country == "United States" )  %>%
summarise(total.sessions = sum(sessions, na.rm=TRUE))
View(agg)

############################### MAKE MAPS ###############################

##### Map 1: any helper list OR resource list #####

# finagle to satisfy function
# combine the two datasets
temp = rbind( dr, dp, fill = TRUE )

chloropleth( .type = c( all.nums ),
             .metric = "sessions",
             .platforms = c("iPhone", "web", "android", "mweb"),
             .start.date = "2018-01-01",
             .end.date = today(),
             .data=temp, 
             .title = "YTD sessions displaying helper list (any reason) or resources" )

setwd("~/Desktop")
width = 8
ggsave( filename = paste("helper_list_or_resources.png"),
        path=NULL, width=width, units="in")



##### Map 2: Resources alone #####
chloropleth( .type = "Resources",
             .metric = "sessions",
             .platforms = c("iPhone", "web", "android", "mweb"),
             .start.date = "2018-01-01",
             .end.date = today(),
             .data=dr, 
             .title = "YTD sessions displaying resources" )

ggsave( filename = paste("resources.png"),
        path=NULL, width=width, units="in")


##### Map 1: Wildlife emergencies #####
chloropleth( .type = wildlife.emerg.nums,
             .metric = "sessions",
             .platforms = c("iPhone", "web", "android", "mweb"),
             .start.date = "2018-01-01",
             .end.date = today(),
             .data=dp, 
             .title = "YTD sessions with wildlife emergencies" )

ggsave( filename = paste("wildlife_emergencies.png"),
        path=NULL, width=width, units="in")

##### Map 1: Wildlife conflicts #####
chloropleth( .type = wildlife.conflict.nums,
             .metric = "sessions",
             .platforms = c("iPhone", "web", "android", "mweb"),
             .start.date = "2018-01-01",
             .end.date = today(),
             .data=dp, 
             .title = "YTD sessions with wildlife conflicts" )

ggsave( filename = paste("wildlife_conflicts.png"),
        path=NULL, width=width, units="in")
