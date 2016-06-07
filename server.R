require(shiny)

shinyServer(function(input, output, session){
  
  ## CREATE REACTIVE VALUES TO TRACK WHERE IN THE DATA FRAME WE ARE
  values <- reactiveValues(ii=1, useDf=curTrackrDf, numImages=nrow(curTrackrDf))
  
  ## GO FORWARD ONE
  observeEvent(input$goNext, {
    values$useDf$curationCode[values$ii] <- input$curVal
    if(values$ii == values$numImages){
      tmpI <- 1
    } else{
      tmpI <- values$ii + 1
    }
    updateRadioButtons(session, 'curVal', 'curation', choices=c('not reviewed'=-1, 'ok'=0, 'omit'=1, 'questionable'=2), selected=values$useDf$curationCode[tmpI])
    values$ii <- tmpI
  })
  
  ## GO BACK ONE
  observeEvent(input$goPrev, {
    values$useDf$curationCode[values$ii] <- input$curVal
    if(values$ii == 1){
      tmpI <- values$numImages
    } else{
      tmpI <- values$ii - 1
    }
    updateRadioButtons(session, 'curVal', 'curation', choices=c('not reviewed'=-1, 'ok'=0, 'omit'=1, 'questionable'=2), selected=values$useDf$curationCode[tmpI])
    values$ii <- tmpI
  })
  
  ## WHICH IMAGE ARE WE ON
  output$healthCode <- renderText({
    values$useDf$healthCode[values$ii]
  })
  output$recordId <- renderText({
    values$useDf$recordId[values$ii]
  })
  
  ## PERCENT DONE
  output$progress <- renderText({
    ct <- sum(values$useDf$curCode == -1)
    paste0(ct, '/', values$numImages, ' images curated (', floor(ct/values$numImages*100), '%)')
  })
  
  ## DISPLAY THE APPROPRIATE IMAGE
  output$displayImage <- renderImage({
    thisLoc <- values$useDf$imageLoc[values$ii]
    list(src = thisLoc,
         contentType = 'image/png')
  }, deleteFile=FALSE)
  
  ## SAVE THE CURATED DATA
  observeEvent(input$saveOutput, {
    tmpDat <- values$useDf
    tmpDat$imageLoc <- NULL
    write.csv(tmpDat, file=file.path("~", "Desktop", paste0("moleMapperCuration-", curator, ".csv")), row.names = FALSE, quote=FALSE)
  })
  
})
