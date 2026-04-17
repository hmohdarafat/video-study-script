# video-study-script
Script to make studying downloaded video courses easier and faster.

Does the following:
- Creates a .csv file that lists:
- All the videos in a sorted order.
- Duration for each of the video
- Challenge (half time of the original video to try to challenge yourself to finish the video in half the time)
- Total time of all the videos
- Total challenge time to finish all the videos
- [!] Script for each video (row) that when run, will start the timer and open the video in your defualt media player.


## Setup:

mkdir -p ~/scripts
download and paste the script file here

## Make it executable

chmod +x ~/scripts/video-study.sh

## Make it global command

sudo ln -s ~/scripts/video-study.sh /usr/local/bin/video-study

## How to use:

cd "Course folder location"
video-study
