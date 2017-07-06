##############################
# title: "Scraping Basketball Reference for last 750 3-Point Attemtps"
# author: "Sameh Awaida"
# date: "7/6/2017"
# Server Side
##############################
# This is the server logic for a Shiny web application.

library(shiny)
library(XML) # for HTML Parse
library(stringr) # for String Match

shinyServer(function(input, output) {
      summaryText <- reactive({
            playersList <- data.frame(playerName = c('Stephen Curry', 'James Harden', 'Eric Gordon', 'Klay Thompson', 'Isaiah Thomas','Jamal Crawford',
                                                     'Vince Carter','Kyle Korver','J.R. Smith','J.J. Redick','Kevin Durant'),
                                      playerID = c('curryst01', 'hardeja01', 'gordoer01', 'thompkl01', 'thomais02','crawfja01',
                                                   'cartevi01','korveky01','smithjr01','redicjj01','duranke01'))
            selectedID <- which(playersList$playerName == input$Player)
            withProgress(message = paste('Getting # of 3PA for ',input$Player), value = 0, {
                  playerID <- playersList$playerID[selectedID]
                  year <- 2017
                  playerURL <- paste('http://www.basketball-reference.com/play-index/event_finder.cgi?request=1&event_code=fg3a&year_id=', 
                                     year, "&player_id=", playerID, sep='')
                  # Increment the progress bar
                  incProgress(0.3)
                  
                  playerDoc <- htmlParse(playerURL)
                  # Check how many attempts for current year
                  dataFGA <- xpathSApply(playerDoc, "//div[@class = 'section_heading']//span[@id = 'found_link']", saveXML) 
                  playerFGA <- as.numeric(unlist(strsplit(str_match(dataFGA, "Found.*3-Point")[,1],' '))[2])
                  incProgress(1)
                 
            })
            
            if (playerFGA >= input$Shots) {
                  withProgress(message = paste('Getting 3PA data & calculating 3FG% for ',input$Player), value = 0, {
                        playerData <- list()
                        if (playerFGA %% 250 == 0) {
                              numberOfPages <- 3
                        } else {numberOfPages <- 4}
                        numberOfPagesMin1 <- numberOfPages - 1
                        for (i in 1:numberOfPages)
                        {
                              # Start from last page
                              playerURL <- paste('http://www.basketball-reference.com/play-index/event_finder.cgi?request=1',
                                                 '&player_id=',playerID,
                                                 '&event_code=fg3a',
                                                 '&year_id=', year, 
                                                 '&offset=', numberOfPagesMin1*250,
                                                 sep='')
                              numberOfPagesMin1 <- numberOfPagesMin1 - 1
                              
                              # Parse Webpage
                              playerDoc <- htmlParse(playerURL)
                              playerNode <- getNodeSet (playerDoc, "//table")
                              playerData <- rbind(readHTMLTable(playerNode[[9]]),playerData)
                              incProgress(i*0.2)
                        }
                        # Remove header information
                        playerData <- subset(playerData, playerData[,1]!="Rk")
                        # Take last 750 rows
                        playerDataLast750 <- tail(playerData,750)
                        
                        # Count number of misses
                        missesList <- lapply(playerDataLast750[,9], function(ch) grep("misses", ch))
                        missesCount <- sum(sapply(missesList, function(x) length(x) > 0))
                        
                        # Count number of makes
                        makesList <- lapply(playerDataLast750[,9], function(ch) grep("makes", ch))
                        makesCount <- sum(sapply(makesList, function(x) length(x) > 0))
                        incProgress(0.9)
                        # Simple error checking
                        if (missesCount + makesCount != 750) print('Something is wrong, sum should be 750 attempts')
                        
                        # 3P%
                        Last750_3P <- round(makesCount*100/750,2)
                        paste('In his last 750 attempt, dating from ',
                              playerDataLast750[1,2], ' to ',
                              tail(playerDataLast750,1)[,2],'\n',
                              playersList$playerName[selectedID], ' made ', makesCount, ' 3 Points Attempts\n',
                              'and missed ', missesCount, ' 3 Points Attempts\n',
                              'With a 3-point percentage of: ', Last750_3P, '%', sep='')
                  })
            }
            else
            {
                  paste(input$Player, ' doesn\'t have ', input$Shots, 
                        ' 3 Point Attempts in the 2016-2017 Season.\n',
                        'He has ', playerFGA, ' 3PA.',sep = '')
            }
      })
      
     
      output$summary <- renderText({ summaryText()  })

})
