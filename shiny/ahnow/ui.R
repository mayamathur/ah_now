

source("startup.R")
source("functions.R")


navbarPage( "AHNow statistics", id = "navbar",
            
            tabPanel( "Basics",
                      sidebarPanel( 
                        
                        textInput(inputId = "password",
                                  label = "Password",
                                  ),
                        
                        dateRangeInput(inputId = "dateRange",
                                  label = "Date range",
                                  start = "2017-1-1",
                                  end = "2017-12-31",
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
                       tableOutput("table"),
                      plotlyOutput("mapPlot", width = "400px", height = "400px")
                        )

                      
            ) # end tabPanel
            
)





