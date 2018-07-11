

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
                        
                        # https://stackoverflow.com/questions/40392676/r-shiny-date-slider-animation-by-month-currently-by-day/40402610
                        sliderInput("Month", "Time animation:",
                                    min=1,
                                    max=12,
                                    value=1,
                                    animate=TRUE ),
                      

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
                        ),

                      mainPanel(

                        h3("Total across platforms"),
                        span( textOutput("grand.total") ),
                        # spinner doesn't work on this one

                        h3("Totals by platform"),
                        withSpinner( tableOutput("table") ),

                        h3("Heat map"),
                        withSpinner( plotlyOutput("mapPlot", width="750px", height="500px") ),
                        
                        # BOOKMARK: ADD THE NEW ANIMATED MAP HERE
                        h4("Animated map"),
                        htmlOutput("aniMap"),
                    

                        h3("Line plot"),
                        withSpinner( plotlyOutput("linePlot") )
                      ) # end mainPanel


                      ), # end tabPanel
                      
                     
            
              tabPanel( "Compare",
                        
                        sidebarPanel( 
                          h4("Compare with respect to:"),
                          selectInput( "type2",
                                       label = "Event type",
                                       choices = c( "Phone dialed" = "PhoneDialed",
                                                    "Animal type filter" = "AnimalTypeFilter",
                                                    "Case flow" = "CaseFlow",
                                                    "Helper detail displayed" = "HelperDetail_Displayed"
                                       ) ),
                          
                          selectInput( "metric2",
                                       label = "Metric to analyze",
                                       choices = c( "Sessions" = "sessions"
                                                    # "Users" = "users"
                                       ) ) ),
                        
                        sidebarPanel(
                          h4("Data slice A"),
                          
                          dateRangeInput(inputId = "dateRange2A",
                                         label = "Date range",
                                         start = "2017-1-1",
                                         end = "2017-12-31",
                                         format = "yyyy-mm-dd"),
                          
                          checkboxGroupInput("platforms2A", "Platforms",
                                             c("iPhone" = "iPhone",
                                               "Android" = "android",
                                               "Mobile web" = "mweb",
                                               "Regular website" = "web"),
                                             selected = c("iPhone", "android", "mweb", "web") ),
                          selectInput( "region2A",
                                       label = "Region",
                                       choices = c( tolower(state.name) )
                                       )
        
                        ),
                        
                        sidebarPanel( 
                          h4("Data slice B"),
                          
                          dateRangeInput(inputId = "dateRange2B",
                                         label = "Date range",
                                         start = "2017-1-1",
                                         end = "2017-12-31",
                                         format = "yyyy-mm-dd"),
                          
                          checkboxGroupInput("platforms2B", "Platforms",
                                             c("iPhone" = "iPhone",
                                               "Android" = "android",
                                               "Mobile web" = "mweb",
                                               "Regular website" = "web"),
                                             selected = c("iPhone", "android", "mweb", "web") ),
                          selectInput( "region2B",
                                       label = "Region",
                                       choices = c( tolower(state.name) )
                          )
                          ),
                      
                        mainPanel(
                          h4("Output"),
                          withSpinner( tableOutput("comparison") )
                        )
                  ) # end tabPanel
                    
            
)





