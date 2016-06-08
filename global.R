require(synapseClient)
synapseLogin()

## FIND OUT WHO IS RUNNING THE APP
un <- synapseClient:::.getCache("username")
if(un=="BrianMBot"){
  curator <- "Brian"
}
if(un=="ChristineSuver"){
  curator <- "Christine"
}
if(un=="MegDoerr"){
  curator <- "Meg"
}

tableId <- "syn4984907"
tab <- synTableQuery(paste0('SELECT * FROM ', tableId))

## GET ALL OF THE IMAGES IN THE TACKING TABLE
curTrackr <- synTableQuery('SELECT * FROM syn6135990')
curTrackrDf <- curTrackr@values

curTrackrDf <- curTrackrDf[curTrackrDf$curator == curator, ]

tab@values <- tab@values[!is.na(tab@values$measurementPhoto.png), ]
tab@values <- tab@values[tab@values$recordId %in% curTrackrDf$recordId, ]
tabDf <- tab@values
imMap <- synDownloadTableColumns(tab, "measurementPhoto.png")

rownames(tabDf) <- tabDf$measurementPhoto.png
tabDf$imageLoc <- unlist(imMap)[rownames(tabDf)]
rownames(tabDf) <- tabDf$recordId
curTrackrDf$imageLoc <- tabDf[curTrackrDf$recordId, "imageLoc"]

possibleMessages <- c("Keep going!", 
                      "These moles aren't going to curate themselves!", 
                      "You can do it!", 
                      "Nice work!", 
                      "Watch out, melanoma!",
                      "OHSU thanks you!",
                      "You're doing great!",
                      "Almost there! (not really)",
                      "Remember, Dan looked at three times as many!")
