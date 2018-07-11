

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
                        
                        # see startup.R for where we read in the types
                        # original script for creating types is in functions.R
                        selectInput( "type",
                                     label = "Event type",
                                     choices = types ),
                        

                        selectInput( "metric",
                                     label = "Metric to analyze",
                                     choices = c( "Sessions" = "sessions",
                                                  "Users" = "users",
                                                 "New users" = "newUsers",
                                                 "Bounces" = "bounces"
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
                        
                        h3("Line plot"),
                        withSpinner( plotlyOutput("linePlot") )
                      ) # end mainPanel


                      ), # end tabPanel
                      
            
            tabPanel( "Animated map",
                      
                      sidebarPanel(
                        # https://stackoverflow.com/questions/40392676/r-shiny-date-slider-animation-by-month-currently-by-day/40402610
                        sliderInput("Month", "Month:",
                                    min=1,
                                    max=12,
                                    value=1,
                                    animate=TRUE )
                        
                      ),
                      
                      mainPanel( 
                        h3("Animated map"),
                        HTML( paste('Enter your parameters in the "Basics" tab.
                                    <br>Choose a date range spanning a full calendar year (01-01 to 12-31).
                                    <br>To play animation, press the blue triangle under the slider.
                                    <br><br>Each map at a given month represents aggregated events for that month. When multiple events occurred close to one another, they are aggregated into a single point that is larger and displayed in a darker color (see legend).
                                    <br>Hover over a point or circle for more information.') ),
                        htmlOutput("aniMap")
                      )
            ), # end tabPanel       
            
            
              tabPanel( "Compare",

                        sidebarPanel(
                          h4("Compare with respect to:"),
                          selectInput( "type2",
                                       label = "Event type",
                                       choices = types ),

                          selectInput( "metric2",
                                       label = "Metric to analyze",
                                       choices = c( "Sessions" = "sessions",
                                                    "Users" = "users",
                                                    "New users" = "newUsers",
                                                    "Bounces" = "bounces"
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
                  ), # end tabPanel
            
            tabPanel( "Helpers",
                      
                      mainPanel( 
                        h3("Distribution of U.S. helpers"),
                        HTML( paste('Hover over a point for more information.') ),
                        withSpinner( plotlyOutput("helperMap") )
                        )
                      )
            
)





