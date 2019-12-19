# The Paper
This repository includes scripts and data for the following paper:

[**Samide, R., Cooper, R.A. & Ritchey, M. (2019). A database of news videos for investigating the dynamics of emotion and memory. Behavior Research Methods, doi:10.3758/s13428-019-01327-w**](https://link.springer.com/article/10.3758/s13428-019-01327-w).


# Abstract
Emotional experiences are known to be both perceived and remembered differently from non-emotional experiences, often leading to heightened encoding of salient visual details and subjectively vivid recollection. The vast majority of previous studies have used static images to investigate how emotional event content modulates cognition, yet natural events unfold over time. Therefore, little is known about how emotion dynamically modulates continuous experience. Here, we report a norming study wherein we develop a new stimulus set of 126 emotionally negative, positive, and neutral videos depicting real-life news events. Participants continuously rated the valence of each video during its presentation and judged the overall emotional intensity and valence at the end of each video. In a subsequent memory test, participants reported how vividly they could recall the video details and estimated each video’s duration. We report data on the affective qualities and subjective memorability of each video. The results replicate the well established effect that emotional experiences are more vividly remembered than non-emotional experiences. Importantly, this novel stimulus set will facilitate research into the temporal dynamics of emotional processing and memory.

# Resources
All files can be found in the [project repository](https://github.com/memobc/paper-videonorming).

To download the video clips, use the script `Download_Video_clips.R`.
- This script reads in the url links for [TV news archive](https://archive.org/details/tv) found in `Video_Summary_Data.xlsx` and returns a .mp4 file for each video.
- Note that the clip downloaded will have a few extra seconds at the beginning compared to the clips we tested. Just trim the beginning of each downloaded video to the start clip time, found in the column `Start Time in URL (s)`.

Summary measures for each video can be found in `Video_Summary_Data.xlsx` and continuous valence ratings at each 0.5s time point can be found in `Video_Continuous_Valence_Data.xlsx`. `Video_Metadata.txt` provides a description of the measures in each of these .xlsx files.

The MATLAB psychtoolbox script to run the paradigm - `video_norm_paradigm.m` - is also included, which loads the stimuli specified in `VideoOrders.mat`.

# Comments?
Please direct any comments to Maureen Ritchey, maureen.ritchey at bc.edu. Please feel free to use these stimuli and data, but unfortunately we cannot provide support for you to adapt them for your experiments.
