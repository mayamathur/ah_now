source("startup.R")

function(input, output, session) {
  
    reactiveData <- reactive({
      if(input$password == "osprey") {
        
        # ~~~ NOT USING API
        get_data(metric = input$metric,
                 start.date = format( input$dateRange[1] ),
                 end.date = format( input$dateRange[2] ) )
      } else {
        stop("Password is incorrect")
      }
    })
    
    reactiveDataSliceA <- reactive({
     # if(input$password == "osprey") {
      # get_data( metric = "sessions",
      #           start.date = "2017-01-01",
      #           end.date = "2017-12-31" )
      
      # # WORKS
      #   d = get_data_no_API( metric = input$metric2,
      #            start.date = format( input$dateRange2A[1] ),
      #            end.date = format( input$dateRange2A[2] ),
      #            region = input$region2A )
        
      # DOES NOT WORK
        d = get_data( metric = input$metric2,
                             start.date = format( input$dateRange2A[1] ),
                             end.date = format( input$dateRange2A[2] ),
                             region = input$region2A )
        
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




    output$fake = renderText({

      d = reactiveDataSliceA()

      stats = summary_stats( .type = "PhoneDialed", .metric = "sessions", .data = d )

        return( paste( "Total ", "sessions", " for ", "PhoneDialed", ": ", stats$grand.tot, sep="" ) )

    })


    # output$comparison = renderTable({
    #   # BOOKMARK: NOT WORKING!!!
    # 
    #   d = reactiveDataSliceA()
    #   #d = reactiveData()
    # 
    #   # # counts for first slice
    #   # summaryA = d %>%
    #   #                 #filter( type == input$type2) %>%
    #   #                 #filter( platform %in% input$platforms2A ) %>%
    #   #                 filter( region %in% input$region2A ) %>%
    #   #                 #filter( date >= input$dateRange2A[1] & date <= input$dateRange2A[2] ) %>%
    #   #                 summarise( total = sum( !!sym(input$metric2) ) )
    # 
    #   #totalA = summaryA$total
    # 
    #   #browser()
    # 
    #   d = d[ d$region == input$region2A, ]
    # 
    #   #return( as.character( input$region2A) ) # works
    #   #return( as.character( dim(d) ) ) # also works
    #   return( as.character( dim(d) ) ) # works
    #   #return(summaryA)
    #   #return( as.character(totalA) )
    # })

}


