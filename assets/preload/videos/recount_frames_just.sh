#!/bin/bash
# from https://www.lifewire.com/bash-for-loop-examples-2200575
# https://stackoverflow.com/a/12152669/9079640
# https://www.baeldung.com/linux/run-multi-line-shell-code
# https://linuxconfig.org/how-to-test-for-installed-package-using-shell-script-on-ubuntu-and-debian
# https://thethemefoundry.com/blog/convert-mp4-to-webm/
# https://superuser.com/a/1121597/1036816
# https://uly.me/ffmpeg-convert-mp3-to-ogg/
# https://bytefreaks.net/gnulinux/bash/ffmpeg-extract-audio-from-mp4-to-ogg
# https://github.com/GrowtopiaFli/openfl-haxeflixel-video-code/
# JOELwindows7: count all frames in each video file

# check ffmpeg
dpkg -s ffmpeg & > $chek
if [ $chek -eq 0 ]; then
    echo "Package ffmpeg is installed!"
else
    echo "Package ffmpeg is NOT installed!"
    sudo apt update
    sudo apt install ffmpeg -y
fi

# count frame and just put frame numbers in it.
for file in ./*.webm
do
filename = (echo $file | cut -f 1 -d '.')
ffprobe -v error -count_frames -select_streams v:0 -show_entries stream=nb_read_frames -of default=nokey=1:noprint_wrappers=1 "$file" > "$filename.txt"
done