#!/bin/bash

# MIT License
# Copyright (c) 2020 Tony Mobily
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# h264 is the compression, mp4 is a container.
# A mp4 video contains h264 compressed frames
#
# The camera generates h264 frames (compressed in real time by the
# hardware)
#
# Their software generates broken h264 files without timing info
#
input=$1
inputBasename=`basename "$input"`

tmpDir=$(mktemp --directory ci-XXXXXXXXXX)

if [ -z "$input" ];then
  echo "Usage: broken264fixer file.264"
  exit 1
fi

if [ ! -f "$USER_PWD/$input" ]; then
  echo "File not found: $USER_PWD/$input"
  exit 1
fi

cp "$USER_PWD"/"$input" "$tmpDir"/input.264
cd $tmpDir

# This will create:
#  * <inputFile>.audio.ts.txt -- Timestamp files for the audio
#  * <inputFile>.video.ts.txt -- Timestamp files for the video
#  * <inputFile>.h264 -- The video file (no audio)
#  * <inputFile>.wav -- The audio file
../convert2 input.264

# This will create:
#  *  <inputFile.mp3> -- The compressed version of the wav audio file. Note: we are actually skipping this step.
# ffmpeg input.mp3 -i input.wav

# This will create
# * <inputFile.mkv> -- A fully working MKV (Matroska) file
#                      See https://www.lifewire.com/mkv-file-4135396
#                      The mkv file will merge the compressed audio (.mp3)
#                      with the extacted h264 file (.h264) using the created
#                      timestamps
../mkvmerge  --output "input.mkv" --timestamps "0:input.video.ts.txt" "input.h264" "input.wav" # or "input.mp3" if created

cd -
mv "$tmpDir/input.mkv" "$USER_PWD"/"${inputBasename}".mkv
rm -rf $tmpDir
