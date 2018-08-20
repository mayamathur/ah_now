

ids = c(75070560, 66336346, 75085662, 66319754)
platforms = c("iPhone", "web", "android", "mweb")

fake = google_analytics( ids[1], 
                         date_range = c( format("2018-01-01"), format("2018-01-15") ),
                         metrics = "sessions",
                         dimensions = c( "date",
                                         "eventAction",
                                         "eventCategory",
                                         "eventLabel",
                                         "region",
                                         "longitude",
                                         "latitude",
                                         "country"),
                         max = -1 )

fake$unique = paste(fake$date, fake$latitude, fake$longitude)

# look at duplicates
fake[ fake$unique == fake$unique[1], ]

