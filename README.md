# The Paper
This repository includes scripts and data for the following paper:

Samide, R., Cooper, R.A., & Ritchey, M. (add info)

# Abstract

# Resources
To download the video clips, use the script `Download_Video_clips.R`. 
- This script reads in the url links for [TV news archive](https://archive.org/details/tv) found in `Video_Summary_Data.xlsx` and returns a .mp4 file for each video. 
- Note that the clip downloaded will have a few extra seconds at the beginning compared to the clips we tested. Just trim the beginning of each downloaded video to the start clip time, found in the column `Start Time in URL (s)`. 

Summary measures for each video can be found in `Video_Summary_Data.xlsx` and continuous valence ratings at each 0.5s time point can be found in `Video_Continuous_Valence_Data.xlsx`. `Video_Metadata.txt` provides a description of the measures in each of these .xlsx files. 

# Comments?
Please direct any comments to Maureen Ritchey, maureen.ritchey at bc.edu. Please feel free to use these stimuli and data, but unfortunately we cannot provide support for you to adapt them for your experiments. 
