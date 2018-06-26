

source("startup.R")
source("functions.R")


navbarPage( "AHNow statistics", id = "navbar",
            
            tabPanel( "Basics",
                      sidebarPanel( 
                        
                        textInput(inputId = "password",
                                  label = "Password",
                                  value=""
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
                        
                        checkboxGroupInput("plotPlatforms", "Platforms to show in plot:",
                                           c("iPhone" = "iPhone",
                                             "Android" = "android",
                                             "Mobile web" = "mweb",
                                             "Regular website" = "web"),
                                           selected = c("iPhone", "android", "mweb", "web") )
                        )

                        
                      ), # end tabPanel
                      
                      mainPanel(
                        
                      h3("Total across platforms"),
                      span( withSpinner( textOutput("grand.total") ) ),
                      
                      h3("Totals by platform"),
                       withSpinner( tableOutput("table") ),
                      
                      h3("Heat map"),
                      withSpinner( plotlyOutput("mapPlot", width="750px", height="500px") ),
                      
                      h3("Line plot"),
                      withSpinner( plotlyOutput("linePlot") )
                      ) # end mainPanel
                    
            
)





