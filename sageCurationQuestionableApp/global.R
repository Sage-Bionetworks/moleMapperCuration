require(synapseClient)
synapseLogin()

## CHECK TO SEE IF PROGRESS HAS BEEN MADE
fPath <- file.path("~", "Desktop", "moleMapperCurationQuestionable.csv")
if(file.exists(fPath)){
  curTrackrDf <- read.csv(fPath, stringsAsFactors = FALSE)
} else{
  tableId <- "syn4984907"
  tab <- synTableQuery(paste0('SELECT * FROM ', tableId))
  
  ## GET ALL OF THE FIRST PASS CALLS
  q <- synQuery('SELECT id, name FROM file WHERE parentId=="syn6173504"')
  res <- lapply(q$file.id, function(x){
    aa <- synGet(x)
    read.csv(getFileLocation(aa), stringsAsFactors = FALSE)
  })
  curTrackrDf <- do.call(rbind, res)
  curTrackrDf$imageLoc <- NULL
  curTrackrDf <- curTrackrDf[which(!(curTrackrDf$curationCode %in% c(0, 1))), ]
  
  tab@values <- tab@values[!is.na(tab@values$measurementPhoto.png), ]
  tab@values <- tab@values[tab@values$recordId %in% curTrackrDf$recordId, ]
  tabDf <- tab@values
  tabDf <- tabDf[ !duplicated(tabDf$recordId), ]
  imMap <- synDownloadTableColumns(tab, "measurementPhoto.png")
  
  rownames(tabDf) <- tabDf$measurementPhoto.png
  tabDf$imageLoc <- unlist(imMap)[rownames(tabDf)]
  rownames(tabDf) <- tabDf$recordId
  curTrackrDf$imageLoc <- tabDf[curTrackrDf$recordId, "imageLoc"]
}

possibleMessages <- c("Keep going!", 
                      "These moles aren't going to curate themselves!", 
                      "You can do it!", 
                      "Nice work!", 
                      "Watch out, melanoma!",
                      "OHSU thanks you!",
                      "You're doing great!",
                      "Almost there! (not really)",
                      "Remember, Dan looked at three times as many!")
