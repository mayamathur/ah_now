
############################### PACKAGE #1 ############################### 

library(googleAnalyticsR)

# http://www.ryanpraski.com/google-analytics-r-tutorial/
# https://www.lunametrics.com/blog/2015/11/23/export-google-analytics-data-with-r/

# list of other packages for GA:
# http://code.markedmondson.me/googleAnalyticsR/index.html

#Authorize Google Analytics R- this will open a webpage
#You must be logged into your Google Analytics account on your web browser
ga_auth()

#Use the Google Analytics Management API to see a list of Google Analytics accounts you have access to
( my_accounts <- google_analytics_account_list() )

#Use my_accounts to find the viewId. Make sure to replace this with your viewId.
my_id <- 36556007

#set date variables for dyanmic date range
start_date <- "60daysAgo"
end_date <- "yesterday"


# show the variables
allowed_metric_dim( type = "METRIC" )
allowed_metric_dim( type = "DIMENSION" )

meta = google_analytics_meta()

#Page View Query
df1 <- google_analytics(my_id, 
                          date_range = c("2018-1-1", "2018-06-01"),
                          metrics = c("ga:sessions"),
                          dimensions = c("ga:date"))

# #Session Query - Uses start_date and end_date
# df2 <- google_analytics_4(my_id, 
#                           date_range = c(start_date, end_date),
#                           metrics = c("sessions"),
#                           dimensions = c("date"))
# 
# #graph sessions by date
# ggplot(data=df2, aes(x=date, y=sessions)) +
#   geom_line(stat="identity")



############################### PACKAGE #2 ############################### 

# https://github.com/skardhamar/rga

rga.open(instance="ga")

start.date <- "30daysAgo"
end.date <- "yesterday"

ga$getData(36556007, start.date, end.date, 
           metrics = "ga:visits", dimensions = "ga:date", 
           sort = "", filters = "", segment = "",
           start = 1, max = 1000)

# same error message! 



