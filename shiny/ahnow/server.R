source("startup.R")

function(input, output, session) {
  
    reactiveData <- reactive({
      get_data(metric = input$metric,
                   start.date = format( input$dateRange[1] ),
                   end.date = format( input$dateRange[2] ) )
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
                     .platforms = c("iPhone", "web", "android", "mweb"),
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
                   .platforms = c("iPhone", "web", "android", "mweb"),
                   .start.date = format( input$dateRange[1] ),
                   .end.date = format( input$dateRange[2] ),
                   .data=d )
      )
      
    })
    
}


