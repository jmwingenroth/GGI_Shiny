library(shiny)
library(bslib)
library(tidyverse)
library(ggplot2)

# input static aluminum 

read.csv("data/second_aluminum_ggi.csv")

second_aluminum_ggi <- read.csv("data/second_aluminum_ggi.csv")
second_aluminum_ggi_cus <- read.csv("data/second_aluminum_ggi_cus.csv")

colors_aluminum <- c("#7f7f7f", "#ffc000")
names(colors_aluminum) <- c("Scrap", "Primary")

# Define UI
ui <- fluidPage(
  # App title ----
  title = "Secondary Aluminum App",
  titlePanel("Secondary Aluminum GGI Emissions by Percent Scrap (tCO2e / tAluminum)"), 
  # Sidebar panel for inputs ----
  sidebarPanel(
    titlePanel(""), 
    selectInput( 
      "scrap_amt", 
      "Select scrap amount", 
      list("0%", "25%", "50%", "75%", "100%")
    )),
  
    # high or low emissions selection for the scenario 
  #  selectInput("cust_second",
  #             "Select emissions scenario for secondary aluminum",
  #              list("Low", "High")),
  
  # Combined aluminum scripts will take input from high / low designations of each primary GGI input 
  # Output: Histogram --
  card(plotOutput(outputId = "scrapPlot"))
  
)

server <- function(input, output) {
  
  output$scrapPlot <- renderPlot({
    
    # get total ggi from custom high / low selections, placeholder names 
   #  custom_ggi_total <- sum(input$Anode, input$AnodePFC, input$Alumina, input$Electrolysis)
    
    # scrap multiplier for primary values 
    # scrap_multiplier <- filter(second_aluminum_gg, Scrap_Amount == input$scrap_amt) %>% .[1,3]
    
  #  scrap_custom_val <- second_aluminum_ggi %>% filter(Scrap_Amount == input$scrap_amt, 
                                                      #  Emissions_Scenario == input$cust_second)
  
   # second_aluminum_ggi_cus <- second_aluminum_ggi_cus %>% filter(Scrap_Amount == input$scrap_amt) 
    
  #  second_aluminum_ggi_cus$GGI_Amount <- c(custom_ggi_total * (1 - scrap_multiplier), scrap_custom_val)
    
    second_aluminum_ggi_plot <- second_aluminum_ggi %>% filter(Scrap_Amount == input$scrap_amt) %>% 
   #   rbind(second_aluminum_ggi_plot, second_aluminum_ggi_cus) %>%
      group_by(Emissions_Scenario) %>% 
      mutate(total_ggi = ifelse(Source == "Scrap", sum(GGI_Amount), ""))
    
    second_aluminum_ggi_plot$Source = factor(second_aluminum_ggi_plot$Source, levels = c("Scrap", "Primary"), ordered = TRUE)
    second_aluminum_ggi_plot$Emissions_Scenario = factor(second_aluminum_ggi_plot$Emissions_Scenario, level = c("Low", "High"), ordered = TRUE)
    
    ggplot(data = second_aluminum_ggi_plot, aes(x = Emissions_Scenario, y = GGI_Amount, fill = Source)) +  
      geom_bar(position = "stack", stat="identity") + 
      scale_fill_manual(values = colors_aluminum, 
                        name = "Emissions Source",
                        labels = c("Scrap", "Primary")) +
      geom_text(aes(label = total_ggi), position= position_stack(1), vjust = -1)  + 
      labs(x = "Emissions Scenario", y = "GGI tCO2e / tSecondary Aluminum", title = "Aluminum GGI Emissions by Scenario (tCO2e / tSecondary Aluminum)") + 
      theme_minimal()
    
  })
  
}

shinyApp(ui = ui, server = server)
