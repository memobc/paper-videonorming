#########################################################
# This script downloads videos from the file
# Video_Summary_Data
#########################################################

#Library the R packages
#Note: you will need to install these package in your version of RStudio.
library(RCurl)
library(openxlsx)

# Make variable for filesep for compatibility with PC or Mac
.Platform$file.sep -> filesep

videoPath <- paste0("~", filesep, "Desktop", filesep, "paper-videonorming-master")

# Set working directory as paper-videonorming folder (wherever you have it downloaded)
setwd(videoPath)

# Determine if running Mac or PC
substr(.Platform$pkgType, start = 1, stop = 3) -> operatingSystem

# Create videos directory to download videos into
dir.create(paste0(videoPath, filesep, "Videos"))

# Download the videos
videos <- read.xlsx('Video_Summary_Data.xlsx')

for(i in 1:nrow(videos)){
  
  # Print video info
  cat(paste("Video #",i,"\n"))
  
  # Download the file!
  
  # If downloading to PC, use mode="wb" and method="wininet" options
  if (operatingSystem=="win") {
    try(
      download.file(videos$URL[i],
                    destfile=paste('.', filesep, 'Videos', filesep, videos$Video.Name[i], sep="", method = "wininet", mode="wb")))
  } # PC loop
  
  else {
    try(
      download.file(videos$URL[i],
                    destfile=paste('.', filesep, 'Videos', filesep, videos$Video.Name[i], sep="")))
  } # Non-PC loop
} # Video loop

#########################################################
