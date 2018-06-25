

source("startup.R")
source("functions.R")


navbarPage( "Animal Help Now! statistics", id = "navbar",
            
            tabPanel( "tab1",
                      sidebarPanel( 
                        
                        
                        selectInput( "outcomeType", label = "Outcome type",
                                     choices = c( "Relative risk / rate ratio" = "RR", 
                                                  "Odds ratio (outcome prevalence <15%)" = "OR.rare",
                                                  "Odds ratio (outcome prevalence >15%)" = "OR.com",
                                                  "Hazard ratio (outcome prevalence <15%)" = "HR.rare",
                                                  "Hazard ratio (outcome prevalence >15%)" = "HR.com",
                                                  # "Linear regression coefficient" = "RG",
                                                  "Standardized mean difference (d)" = "MD", 
                                                  "Risk difference" = "RD" ) )
                        
                        
                        #sidebarPanel(  HTML(paste("<b>Computing an E-value</b>")) )
                        
                      ), # end mainPanel
                      
                      mainPanel(  span( textOutput("grand.total") ) )
                      
            ) # end tabPanel
            
)





