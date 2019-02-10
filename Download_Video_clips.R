#########################################################
# This script downloads videos from the file
# Video_Summary_Data
#########################################################

#Library the R packages
#Note: you will need to install these package in your version of RStudio.
library(RCurl)
library(openxlsx)

#Download the videos
videos <- read.xlsx('Video_Summary_Data.xlsx')
for(i in 1:nrow(videos)){
  cat(paste("Video #",i,"\n"))
  # download the file!
  download.file(videos$URL[i],
                destfile=paste('./Videos/',videos$Video.Name[i],sep=""))
}

#########################################################
