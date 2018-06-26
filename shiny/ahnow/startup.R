

library(googleAnalyticsR)
library(dplyr)
library(rlang)
library(lubridate)
library(plotly)
library(fiftystater)
library(ggplot2)
library(mapproj)
library(shinycssloaders)  # for loading spinners

# https://github.com/MarkEdmondson1234/googleAnalyticsR/issues/126
ga_auth(".httr-oauth")

# keeps original error messages
options(shiny.sanitize.errors = FALSE)


