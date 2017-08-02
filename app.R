library(shiny)
library(deSolve)
library(highcharter)
library(lubridate)
library(purrr)
library(tidyr)
library(ggplot2)
library(shinyBS)
library(ggthemes)

## -- helper function from http://archives.aidanfindlater.com/blog/2010/04/20/the-basic-sir-model-in-r/
sir <- function(time, state, parameters) {
  with(as.list(c(state, parameters)), {
    dS <- -beta * S * I
    dI <- beta * S * I - gamma * I
    dR <- gamma * I
    
    return(list(c(dS, dI, dR)))
  })
}
init <- c(S = 1-1e-6, I = 1e-6, R = 0.0)
times <- seq(0, 60, by = 0.1)
init_params <- c(1.5, 7)

## -- shiny app
ui <- htmlTemplate("index.html",
  res_plot = plotOutput("res"),
  beta_slider = sliderInput("beta", label = "Zombie / Human Interactions Per Day", min = 1, step = 0.25, max = 5, init_params[1]),
  gamma_slider = sliderInput("gamma", label = "Zombie Life Span (days)", min = 1, max = 15, init_params[2]),
  reset_button = actionButton("reset", "Reset Controls"),
  txt_output = htmlOutput("txt")
)

# ui <- fluidRow(
#   highchartOutput("results"),
#   sliderInput("beta", label = "Transmission Rate (days)", min = 1, max = 10, value = init_params[1]),
#   sliderInput("gamma", label = "Recovery Rate (days)", min = 1, max = 100, value = init_params[2]),
#   actionButton("reset", "reset")
# )

server <- function(input, output, session) {

  parameters <- reactive({
    c(beta = input$beta, gamma = 1/input$gamma)
  })
 
  out <- reactive({
    params <- parameters()
    as.data.frame(ode(y = init, times = times, func = sir, parms = params))
  }) 
  
  output$res <- renderPlot({
    out <- out()
    colnames(out) <- c("time", "Humans", "Zombies", "Dead")
    out <- map_df(out, ~round(.x, 2))
    out$time <- seq(today(), today()+ddays(60), by = 0.1)
    out <- out %>% 
      gather(key = "Categories", value = "Class", -time)
    ggplot(out, aes(x = time, y = Class)) + 
      geom_line(aes(color = Categories)) +
      scale_y_continuous(labels = function(x){paste0(x*100, "%")}) +
      theme_fivethirtyeight() +
      labs(
        title = "Did we survive?",
        subtitle = "Populations Over Time",
        color = NULL,
        ylab = "",
        xlab = ""
      ) +
      theme(
        plot.background = element_rect(fill = "white"),
        panel.background = element_rect(fill = "white"),
        legend.background = element_rect(fill = "white"),
        title = element_text(family = "Source Sans Pro")
      ) +
      scale_color_manual(
        values = c("#e6553a","#75aadb", "#a3c586")
      )
  })
    
    output$txt <- renderText({
      out <- out()
      humans <- round(out[nrow(out), "S"]*100)
      if (humans > 0) {
        txt <- paste0("Congratulations! Humans survived with ", humans, "% of the population remaining!")
      } else {
    txt <- "Unfortunately all the humans died. RIP"
      }
      paste0("<p> ",txt,"<p>")
    })

  
  # output$results <- renderHighchart({
  #   out <- out()
  #   colnames(out) <- c("time", "S", "I", "R")
  #   out <- map(out, ~round(.x, 2))
  #   out$time <- seq(today(), today()+dyears(1), by = 1)
  #   hc <- highchart() %>% 
  #     hc_xAxis(out$time) %>% 
  #     hc_add_series(name = "Humans", data = out$S*100) %>% 
  #     hc_add_series(name = "Zombies", data = out$I*100) %>% 
  #     hc_add_series(name = "Immune", data = out$R*100) %>% 
  #     hc_tooltip(
  #       formatter = JS("function(){return '<b>'+ this.series.name +'</b>: '+ this.point.y +'%'; }")
  # 
  #     ) %>% 
  #     hc_add_theme(hc_theme_538()) %>% 
  #     hc_title(text = "Population Over 1 Year")
  #   browser()
  #   hc
  # })
  
  observeEvent(input$reset, {
    updateSliderInput(session, "beta", value = init_params[1])
    updateSliderInput(session, "gamma", value = init_params[2])
  })
}

shinyApp(ui, server)