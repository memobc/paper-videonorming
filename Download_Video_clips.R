#########################################################
# This scripts downloads videos from the file
# Video_Summary_Data.csv
#########################################################

#Library the R packages
#Note: you will need to install these package in your version of Rstudio.
library(RCurl)
library(openxlsx)

#Download the videos
videos <- read.xlsx('Video_Summary_Data.xlsx')

for(i in 104:nrow(videos)){
  # let user know what video # we are on
  cat(paste("Video #",i,"\n"))
  
  # download the file!
  download.file(videos$URL[i],
                destfile=paste('./Videos/',videos$Video.Name[i],sep=""))
}

#########################################################
