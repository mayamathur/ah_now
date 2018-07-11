source("startup.R")

function(input, output, session) {
  
    reactiveData <- reactive({
      if(input$password == "osprey") {
        
        # subset to chosen platforms
        get_data( metric = input$metric,
                 start.date = format( input$dateRange[1] ),
                 end.date = format( input$dateRange[2] ),
                 .platforms = input$plotPlatforms )
      } else {
        stop("Password is incorrect")
      }
    })
    
    reactiveDataSliceA <- reactive({

        d = get_data( metric = input$metric2,
                             start.date = format( input$dateRange2A[1] ),
                             end.date = format( input$dateRange2A[2] ),
                             region = input$region2A,
                            .platforms = input$platforms2A )
        
        return(d)
    #  } else {
    #    stop("Password is incorrect")
    #  }
    })
    
    reactiveDataSliceB <- reactive({
      
      d = get_data( metric = input$metric2,
                    start.date = format( input$dateRange2B[1] ),
                    end.date = format( input$dateRange2B[2] ),
                    region = input$region2B,
                    .platforms = input$platforms2B )
      
      return(d)
      #  } else {
      #    stop("Password is incorrect")
      #  }
    })
    

    output$table = renderTable({
      d = reactiveData()

      stats = summary_stats( .type = input$type, .metric = input$metric, .data = d )
      return( as.data.frame(stats$platform.tot ) )

    }, digits=0)

    
    output$grand.total = renderText({

      d = reactiveData()

      stats = summary_stats( .type = input$type, .metric = input$metric, .data = d )

        return( paste( "Total ", input$metric, " for ", input$type, ": ", stats$grand.tot, sep="" ) )

    })

    output$mapPlot = renderPlotly({
      d = reactiveData()
      ggplotly(
        chloropleth( .type = input$type,
                     .metric = input$metric,
                     .platforms = input$plotPlatforms,
                     .start.date = format( input$dateRange[1] ),
                     .end.date = format( input$dateRange[2] ),
                     .data=d )
      )

    })
    
    # BOOKMARK
    # animated map
    # Example 3 of: https://magesblog.com/post/2013-02-26-first-steps-of-using-googlevis-on-shiny/
    output$aniMap = renderGvis({
      
      d = reactiveData()
       temp = d[ d$type == input$type, ]
      
       
       temp$latlon = paste( temp$latitude, ":", temp$longitude, sep="" )

      gvisGeoChart( temp,
                    locationvar = "latlon",
                      colorvar = input$metric )

    })
    

    output$linePlot = renderPlotly({
      d = reactiveData()

      ggplotly(
        line_plot( .type = input$type,
                   .metric = input$metric,
                   .platforms = input$plotPlatforms,
                   .start.date = format( input$dateRange[1] ),
                   .end.date = format( input$dateRange[2] ),
                   .data=d )
      )

    })




    output$comparison = renderTable({
      
      #browser()

      a = reactiveDataSliceA()
      b = reactiveDataSliceB()

      statsA = summary_stats( .type = input$type2, .metric = input$metric2, .data = a )
      statsB = summary_stats( .type = input$type2, .metric = input$metric2, .data = b )
      
      return( data.frame( "Data slice" = c("A", "B", "Difference B-A"),
                          "Total" = c(statsA$grand.tot, statsB$grand.tot, statsB$grand.tot - statsA$grand.tot) ) )
    

        # return( paste( "Total ", input$metric2, " for ", input$type2, " for slice A: ", statsA$grand.tot,
        #                "\nTotal ", input$metric2, " for ", input$type2, " for slice B: ", statsB$grand.tot, 
        #                sep="" ) )
      
      

    }, digits = 0)

}


