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
    aniMonth <- reactive({
      input$Month
    })
    
    
    output$aniMap = renderGvis({
      
      # check that user specified a full calendar year
      # allow for both normal years (364) and leap years (365)
      date.span = as.numeric(as.Date(input$dateRange[2]) - as.Date(input$dateRange[1]) )
      if ( !date.span %in% c(364, 365) ) {
        stop( 'On the "Basics" tab, must enter a full calendar year from 01-01 to 12-31 to see animated map.')
      }
      
      d = reactiveData()
       temp = d[ d$type == input$type & d$month == aniMonth(), ]
      
       temp$latlon = paste( temp$latitude, ":", temp$longitude, sep="" )

      gvisGeoChart( temp,
                    locationvar = "latlon",
                    colorvar = input$metric,
                    options = list( region = "US"
                                     )
                    )

    })
    
    
    output$helperMap = renderPlotly({
      
      # use static helper data
      # remove missing data
      f = f[ !is.na(f$Latitude) & !is.na(f$Longitude), ]
      f$Latitude = as.numeric( as.character(f$Latitude) )
      f$Longitude = as.numeric( as.character(f$Longitude) )
      
      # bounding box around continental US
      top = 49.3457868 # north lat
      left = -124.7844079 # west long
      right = -66.9513812 # east long
      bottom =  24.7433195 # south lat
      
      f = f %>% filter( Latitude >= bottom & Latitude <= top ) %>%
        filter( Longitude >= left & Longitude <= right )
      
      # for hovering over points
      f$string = paste( f$Name_Pub, " (", f$HelperType_Pub, ")", sep="" )
      
      #browser()
      
      states = map_data("state")
      
      p = ggplot(data = states) + 
        geom_polygon(aes(x = long, y = lat, group = group), color = "black", fill="white") + 
        
        # in the below, "text" argument is what shows up on point hover
        geom_point( data = f, aes( x = Longitude, y = Latitude, text=string ), color = "red", alpha = 0.4, size = 1 ) +
        coord_fixed(1.3) +
        guides(fill=FALSE) +
        theme_classic() +
        xlab("Longitude") +
        ylab("Latitude")
      
      ggplotly(p)
      
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


