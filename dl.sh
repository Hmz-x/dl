#!/bin/sh

# POSIX compliant script for downloading content to a directory using youtube-dl.
# Change configuration options to suit your needs.

# Basic configuration
ytdl_opt="-x" # parameter passed to youtube-dl
link_file="/home/hkm/Programming/Bash_Scripts/dl.conf" # file containing the links of the media
# link_file's first line should be the directory to which the content is to be downloaded; the rest should be links.

# Error checking
[ -z "$(which youtube-dl)" ] && printf "youtube-dl not in path. Exitting.\n" >&2 && exit 1
[ -z "$(which ffmpeg)" ] && printf "ffmpeg not in path. Exitting.\n" >&2 && exit 1
[ ! -r "$link_file" ] && printf "Unable to read link file. Exitting.\n" >&2 && exit 1

dl_links(){
count=0
while read line; do
	if [ "$count" -eq 0 ]; then
		dir="$line"
		[ ! -d "$dir" ] || { mkdir "$dir" ||  { printf "Unable to make directory $dir. Exitting.\n" >&2 && exit 1; } }

		# Download all links to temp directory 
		temp_dir="$(mktemp -d)"
		cd "$temp_dir"
	else
		youtube-dl "$ytdl_opt" "$line"	
	fi
	count=$((count+1))

done < "$link_file"
}

convert(){
	for file in *; do
		

# Read links and dir from file. Download links to a temp dir.
dl_links

rm -rf "$temp_dir"
