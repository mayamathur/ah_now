

source("startup.R")
source("functions.R")


navbarPage( "AHNow statistics", id = "navbar",
            
            tabPanel( "Basics",
                      sidebarPanel( 
                        
                        textInput(inputId = "password",
                                  label = "Password"
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
                                     ) )
                        )

                        
                      ), # end tabPanel
                      
                      mainPanel(
                        
                      h3("Grand total"),
                      span( textOutput("grand.total") ),
                      
                      h3("Totals by platform"),
                       tableOutput("table"),
                      
                      h3("Heat map"),
                      plotlyOutput("mapPlot"),
                      
                      h3("Line plot"),
                      plotlyOutput("linePlot")
                      ) # end mainPanel
                    
            
)





