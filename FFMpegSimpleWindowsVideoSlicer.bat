@ECHO off

REM **********************
REM FFMpegSimpleWindowsVideoSlicer
REM Notes:
REM This simple program I quickly made currently only works with .MPG type videos. More types
REM may be supported in the future. This currently allow up to 6 slices (7 subvideos). Slices
REM are indicated by slice point arguments. Slice points indicate time indexes. Slice points
REM must be of a time index < the end time of the video and > the start time of 0. Slice
REM points need to come after the total video time argument. Slice points must be in reverse
REM chronological order. You must also include the original video's total run time (you can
REM error on the side of caution and round up a second or two). You must also include the
REM directory to your ffmpeg install location.
REM Here is the call format for this program:
REM FFMpegSimpleWindowsVideoSlicer FfmpegLocation VideoFileLocation VideosTotalTime SlicePoint1 [SlicePoint2 ... SlicePoint6]
REM Here is a sample call:
REM FFMpegSimpleWindowsVideoSlicer C:/your/dir/to/ffmpeg C:/your/dir/videofile.mpg 02:01:00.0 01:33:25.5 00:09:09.0
REM **********************

REM Check to make sure there are enough arguments:
SET HasEnoughArguments=1
IF "%~1"=="" (
  SET HasEnoughArguments=0
) ELSE (
  IF "%~2"=="" (
    SET HasEnoughArguments=0 
  ) ELSE (
    IF "%~3"=="" (
	  SET HasEnoughArguments=0
    ) ELSE (
      IF "%~4"=="" (SET HasEnoughArguments=0)
    )
  )
)

REM Stop the program if there were not enough arguments given:
IF "%HasEnoughArguments%"=="0" (
  ECHO Not enough arguments given
  EXIT /B 0
)

ECHO **********************
ECHO Begin Program
ECHO **********************

SET FFMpeg=%1
SET videoFile=%2
SET vidStart=00:00:00.0
SET vidEnd=%3
SET numSubVideos=2
SET startSliceAt=%4
SET endSliceAt=%3
SET srcTemp1File=%videoFile%temp1.mpg
SET srcTemp2File=%videoFile%temp2.mpg
SET finalFile1=%videoFile%slice1.mpg
SET finalFile2=%videoFile%slice2.mpg
SET finalFile3=%videoFile%slice3.mpg
SET finalFile4=%videoFile%slice4.mpg
SET finalFile5=%videoFile%slice5.mpg
SET finalFile6=%videoFile%slice6.mpg
SET finalFile7=%videoFile%slice7.mpg

REM Update the total number of videos based on the number of slice points sent into the arguments:
IF NOT "%~5"=="" (SET numSubVideos=3)
IF NOT "%~6"=="" (SET numSubVideos=4)
IF NOT "%~7"=="" (SET numSubVideos=5)
IF NOT "%~8"=="" (SET numSubVideos=6)
IF NOT "%~9"=="" (SET numSubVideos=7)

REM Check if the new sub video filenames already exist:
SET aSubVideoNameAlreadyExists=0
IF EXIST %srcTemp1File% (SET aSubVideoNameAlreadyExists=1)
IF EXIST %srcTemp2File% (SET aSubVideoNameAlreadyExists=1)
IF EXIST %finalFile1% (SET aSubVideoNameAlreadyExists=1)
IF EXIST %finalFile2% (SET aSubVideoNameAlreadyExists=1)
IF EXIST %finalFile3% (SET aSubVideoNameAlreadyExists=1)
IF EXIST %finalFile4% (SET aSubVideoNameAlreadyExists=1)
IF EXIST %finalFile5% (SET aSubVideoNameAlreadyExists=1)
IF EXIST %finalFile6% (SET aSubVideoNameAlreadyExists=1)
IF EXIST %finalFile7% (SET aSubVideoNameAlreadyExists=1)
IF "%aSubVideoNameAlreadyExists%"=="1" (
  ECHO A temporary or sub video file name already exists. Please move or delete those files first.
  EXIT /B 0
)

REM Create the first video by making a copy of the source video with it's beginning sliced off:
ECHO *********************************************
ECHO Creating first sub video:
ECHO *********************************************
%FFMpeg% -ss %startSliceAt% -i %videoFile% -c:v copy -c:a copy -fflags +genpts -t %endSliceAt% -f dvd %finalFile7%

REM Create the new source video by making a copy of the source video with it's end sliced off:
ECHO *********************************************
ECHO Creating new source video:
ECHO *********************************************
%FFMpeg% -ss %vidStart% -i %videoFile% -c:v copy -c:a copy -fflags +genpts -t %startSliceAt% -f dvd %srcTemp1File%

Rem If we're only doing 2 sub videos, then exit:
IF "%numSubVideos%"=="2" (
  EXIT /B 0
)
Rem Else, continue and update slice point:
SET startSliceAt=%5

REM Create the next video by making a copy of the temp video with it's beginning sliced off:
ECHO *********************************************
ECHO Creating next sub video:
ECHO *********************************************
%FFMpeg% -ss %startSliceAt% -i %srcTemp1File% -c:v copy -c:a copy -fflags +genpts -t %endSliceAt% -f dvd %finalFile6%

REM Create the new source video by making a copy of the source video with it's end sliced off:
ECHO *********************************************
ECHO Creating new source video:
ECHO *********************************************
%FFMpeg% -ss %vidStart% -i %srcTemp1File% -c:v copy -c:a copy -fflags +genpts -t %startSliceAt% -f dvd %srcTemp2File%

Rem Delete temp file so we can easily recreate it next time:
DEL %srcTemp1File%

Rem If we're only doing 3 sub videos, then exit:
IF "%numSubVideos%"=="3" (
	EXIT /B 0
)
Rem Else, continue and update slice point:
SET startSliceAt=%6

REM Create the next video by making a copy of the temp video with it's beginning sliced off:
ECHO *********************************************
ECHO Creating next sub video:
ECHO *********************************************
%FFMpeg% -ss %startSliceAt% -i %srcTemp2File% -c:v copy -c:a copy -fflags +genpts -t %endSliceAt% -f dvd %finalFile5%

REM Create the new source video by making a copy of the source video with it's end sliced off:
ECHO *********************************************
ECHO Creating new source video:
ECHO *********************************************
%FFMpeg% -ss %vidStart% -i %srcTemp2File% -c:v copy -c:a copy -fflags +genpts -t %startSliceAt% -f dvd %srcTemp1File%

Rem Delete temp file so we can easily recreate it next time:
DEL %srcTemp2File%

Rem If we're only doing 4 sub videos, then exit:
IF "%numSubVideos%"=="4" (
  EXIT /B 0
)
Rem Else, continue and update slice point:
SET startSliceAt=%7

REM Create the next video by making a copy of the temp video with it's beginning sliced off:
ECHO *********************************************
ECHO Creating next sub video:
ECHO *********************************************
%FFMpeg% -ss %startSliceAt% -i %srcTemp1File% -c:v copy -c:a copy -fflags +genpts -t %endSliceAt% -f dvd %finalFile4%
	
REM Create the new source video by making a copy of the source video with it's end sliced off:
ECHO *********************************************
ECHO Creating new source video:
ECHO *********************************************
%FFMpeg% -ss %vidStart% -i %srcTemp1File% -c:v copy -c:a copy -fflags +genpts -t %startSliceAt% -f dvd %srcTemp2File%

Rem Delete temp file so we can easily recreate it next time:
DEL %srcTemp1File%

Rem If we're only doing 5 sub videos, then exit:
IF "%numSubVideos%"=="5" (
	EXIT /B 0
)
Rem Else, continue and update slice point:
SET startSliceAt=%8

REM Create the next video by making a copy of the temp video with it's beginning sliced off:
ECHO *********************************************
ECHO Creating next sub video:
ECHO *********************************************
%FFMpeg% -ss %startSliceAt% -i %srcTemp2File% -c:v copy -c:a copy -fflags +genpts -t %endSliceAt% -f dvd %finalFile3%
	
REM Create the new source video by making a copy of the source video with it's end sliced off:
ECHO *********************************************
ECHO Creating new source video:
ECHO *********************************************
%FFMpeg% -ss %vidStart% -i %srcTemp2File% -c:v copy -c:a copy -fflags +genpts -t %startSliceAt% -f dvd %srcTemp1File%

Rem Delete temp file to avoid confusion:
DEL %srcTemp2File%

Rem If we're only doing 6 sub videos, then exit:
IF "%numSubVideos%"=="6" (
	EXIT /B 0
)
Rem Else, continue and update slice point:
SET startSliceAt=%9

REM Create the next video by making a copy of the temp video with it's beginning sliced off:
ECHO *********************************************
ECHO Creating next sub video:
ECHO *********************************************
%FFMpeg% -ss %startSliceAt% -i %srcTemp1File% -c:v copy -c:a copy -fflags +genpts -t %endSliceAt% -f dvd %finalFile2%
	
REM Create the new source video by making a copy of the source video with it's end sliced off:
ECHO *********************************************
ECHO Creating new source video:
ECHO *********************************************
%FFMpeg% -ss %vidStart% -i %srcTemp1File% -c:v copy -c:a copy -fflags +genpts -t %startSliceAt% -f dvd %finalFile1%

Rem Delete temp file to avoid confusion:
DEL %srcTemp1File%

EXIT /B 0
