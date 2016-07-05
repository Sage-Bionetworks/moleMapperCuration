require(synapseClient)
synapseLogin()

## GET THE FIRST PASS OF CURATION
q <- synQuery('SELECT id, name FROM file WHERE parentId=="syn6173504"')

res <- lapply(q$file.id, function(x){
  aa <- synGet(x)
  read.csv(getFileLocation(aa), stringsAsFactors = FALSE)
})

allData <- do.call(rbind, res)
allData$imageLoc <- NULL
allData <- allData[ !duplicated(allData$recordId), ]
allData$reReview <- NA
rownames(allData) <- allData$recordId

## GET THE QUESTIONABLE CALLS
qCalls <- read.csv(getFileLocation(synGet("syn6183535")), stringsAsFactors = FALSE)
rownames(qCalls) <- qCalls$recordId

allData$reReview <- qCalls[rownames(allData), "curationCode"]
allData$sageCall <- allData$curationCode
allData$sageCall[ allData$sageCall %in% c(-1, 2) ] <- allData$reReview[ allData$sageCall %in% c(-1, 2) ]

## GET DAN W. CALLS
danCalls <- read.csv(getFileLocation(synGet("syn6182794")), stringsAsFactors = FALSE)
## COLLAPSE THE DUPLICATES (BE CONSERVATIVE - IF EITHER FLAGGED, FLAG FINAL)
theseDups <- danCalls$recordId[duplicated(danCalls$recordId)]
for(i in theseDups){
  idx <- danCalls$recordId == i
  danCalls$Identifiable[idx] <- as.integer(sum(danCalls$Identifiable[idx])>0)
  danCalls$Invalid[idx] <- as.integer(sum(danCalls$Invalid[idx])>0)
}
danCalls <- danCalls[ !duplicated(danCalls$recordId), ]
rownames(danCalls) <- danCalls$recordId

allData$danCall <- danCalls[allData$recordId, "Identifiable"]
allData$combinedCall <- as.integer(allData$sageCall+allData$danCall > 0)
allData$danInvalid <- danCalls[allData$recordId, "Invalid"]

tcs <- as.tableColumns(allData)
finalTracker <- synStore(Table(TableSchema(name = "Image Curation - Final", parent="syn6126493", columns = tcs$tableColumns), values = tcs$fileHandleId))
