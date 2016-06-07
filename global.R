## SET WHO IS RUNNING THIS APP FIRST (ONE OF Brian, Christine, or Meg)
curator <- "Brian"

require(synapseClient)
synapseLogin()

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

