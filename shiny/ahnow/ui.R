

source("startup.R")
source("functions.R")


navbarPage( "Animal Help Now! statistics", id = "navbar",
            
            tabPanel( "Basics",
                      sidebarPanel( 
                        
                        textInput(inputId = "password",
                                  label = "Password",
                                  ),
                        
                        dateInput(inputId = "startDate",
                                  label = "Start date",
                                  value = "2017-12-31",
                                  format = "yyyy-mm-dd"),
                        
                        dateInput(inputId = "endDate",
                                  label = "Start date",
                                  value = "2017-01-01",
                                  format = "yyyy-mm-dd"),
                        
                        selectInput( "type",
                                     label = "Event type",
                                     choices = c( "Phone dialed" = "PhoneDialed",
                                                  "Animal type filter" = "AnimalTypeFilter",
                                                  "Case flow" = "CaseFlow",
                                                  "Helper detail displayed" = "HelperDetail_Displayed"
                                                   ) ),
                        
                        selectInput( "metric",
                                     label = "Metric to analyze",
                                     choices = c( "Sessions" = "sessions"
                                                 # "Users" = "users"
                                     ) ),
                        
                        selectInput( "plotType",
                                     label = "Plot type",
                                     choices = c( "Map" = "map",
                                                  "Line" = "line"
                                                
                                     ) )

                        
                      ), # end mainPanel
                      
                      mainPanel(
                        span( textOutput("grand.total") ),
                        span( textOutput("passedDate") ),
                        span( textOutput("hardCodedDate") )
                        )

                      
            ) # end tabPanel
            
)





