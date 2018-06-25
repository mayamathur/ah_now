source("startup.R")

function(input, output, session) {
  

    reactiveData <- reactive({
      get_data(metric = input$metric,
                   start.date = format( input$dateRange[1] ),
                   end.date = format( input$dateRange[2] ) )
    })

  #d = get_data(metric = input$metric, start.date = "2017-01-01", end.date = "2017-12-31")
  
  
    output$table = renderTable({
      d = reactiveData()
      
      stats = summary_stats( .type = input$type, .metric = input$metric, .data = d )
      return( as.data.frame(stats$platform.tot ) )
      
      # fake = data.frame( X = rnorm(10),  Y=rnorm(10))
      # return(fake)
    })
  
    output$grand.total = renderText({
      
      # BOOKMARK: SHOULD PROBABLY MOVE THIS ELSEWHERE BECAUSE I DON'T THINK IT'S A GLOBAL VARIABLE
      # THAT WAY THE TABLE CAN ALSO ACCESS IT
      # https://stackoverflow.com/questions/22834778/r-shiny-daterangeinput-format
      # d = get_data(metric = input$metric,
      #              start.date = format( input$dateRange[1] ),
      #              end.date = format( input$dateRange[2] )  )
      
      d = reactiveData()

      stats = summary_stats( .type = input$type, .metric = input$metric, .data = d )
      
        return( paste( "Total ", input$metric, " for ", input$type, ": ", stats$grand.tot, sep="" ) )
    
    })
  

    
    # output$curveOfExplainAway <- renderPlotly({
    #     
    #   # MM: do not attempt to make plot unless we have the point estimate
    #     if( !is.na( bias.factor() ) ) {
    #   
    #     rr.ud <- function(rr.eu) {
    #         
    #         if(bias.factor() > 1){
    #           
    #             ( bias.factor()*(1 - rr.eu) )/( bias.factor() - rr.eu )
    #             
    #         }else{
    #             
    #             ( (1/bias.factor())*(1 - rr.eu) )/( (1/bias.factor()) - rr.eu )
    #         }
    #     }
    #     
    #     g <- ggplotly(
    #         ggplot(data.frame(rr.eu = c(0, 20)), aes(rr.eu)) + 
    #             stat_function(fun = rr.ud) + 
    #             scale_y_continuous(limits = c(1, evals()[1]*3)) + 
    #             scale_x_continuous(limits = c(1, evals()[1]*3)) +
    #             xlab("Risk ratio for exposure-confounder relationship") + ylab("Risk ratio for confounder-outcome relationship") + 
    #             geom_point(dat = data.frame(rr.eu = evals()[1], rr.ud = evals()[1]), aes(rr.eu, rr.ud)) +
    #             geom_text(dat = data.frame(rr.eu = evals()[1], rr.ud = evals()[1]), 
    #                       aes(rr.eu, rr.ud), 
    #                       label = paste0("E-value:\n (", round(evals()[1], 2), ",", round(evals()[1], 2),")"),
    #                       nudge_x = evals()[1]*(3/5), size = 3) + 
    #             theme_minimal()
    #     )
    #     
    #     g$x$data[[2]]$text <- "E-value"
    #     g$x$data[[1]]$text <- gsub("y", "RR_UD", g$x$data[[1]]$text)
    #     g$x$data[[1]]$text <- gsub("rr.eu", "RR_EU", g$x$data[[1]]$text)
    #     
    #     return(g)
    #     
    #     } else {
    #       # if we don't have point estimate, 
    #       # then show blank placeholder graph
    #       df = data.frame()
    #       g = ggplotly( ggplot(df) +
    #                       geom_point() +
    #                       xlim(0, 10) +
    #                       ylim(0, 10) +
    #                       theme_minimal() +
    #                       xlab("Risk ratio for exposure-confounder relationship") + ylab("Risk ratio for confounder-outcome relationship") + 
    #                       annotate("text", x = 5, y = 5, label = "(Enter your point estimate)") )
    #       return(g)
    #     }
    # }) 

}


