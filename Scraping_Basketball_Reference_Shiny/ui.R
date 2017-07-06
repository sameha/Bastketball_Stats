##############################
# title: "Scraping Basketball Reference for last 750 3-Point Attemtps"
# author: "Sameh Awaida"
# date: "7/6/2017"
# UI Side
##############################

library(shiny)

# Define UI for dataset viewer application
shinyUI(pageWithSidebar(
      
      # Application title
      headerPanel("Scraping basketball-reference.com for last 750 3-Point Attemtps"),
      
      # Sidebar with controls to select a player
      sidebarPanel(
            selectInput("Player", "Choose a player:", 
                        choices = c('Stephen Curry', 'James Harden', 'Eric Gordon', 'Klay Thompson', 'Isaiah Thomas','Jamal Crawford',
                                    'Vince Carter','Kyle Korver','J.R. Smith','J.J. Redick','Kevin Durant')),
            numericInput("Shots", "Last number of 3 Point Attempts:", 750)
      ),
      
      # Show a summary of the dataset and an HTML table with the requested
      # number of observations
      mainPanel(
            verbatimTextOutput("summary")
      )
))