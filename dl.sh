#!/bin/sh

# POSIX compliant script for downloading content to a directory using youtube-dl.
# Change configuration options to suit your needs. link_file MUST be modified.

# Basic configuration
link_file="/home/hkm/Programming/POSIX_Scripts/dl/dl.conf" # full path of file containing the links of the media
# The file's first line should be the directory to which the content is to be downloaded, the rest should be links. See: dl_links function
new_format="mp3" # downloaded content will be converted into this format
ytdl_opt="-x" # parameter passed to youtube-dl
lib_file="$(dirname $0)/util.sh" # No need to change

# Source function library file
. "$lib_file" || { printf "Unable to source $function_file. Exitting.\n" >&2 && exit 1; }

# Error checking
[ -z "$(which youtube-dl)" ] && err "youtube-dl not in path."
[ -z "$(which ffmpeg)" ] && err "ffmpeg not in path. Exitting."
[ ! -r "$link_file" ] && err "Unable to read link file. Exitting."

dl_links(){
count=0
while read line; do
	if [ "$count" -eq 0 ]; then
		content_dir="$line"
		[ ! -d "$content_dir" ] || { mkdir "$content_dir" || err "Unable to make directory $content_dir."; }

		# Download all links to temp directory 
		temp_dir="$(mktemp -d)" && cd "$temp_dir"
		[ "$?" -ne 0 ] && err "Unable to cd into temporary directory."
	else
#		youtube-dl "$ytdl_opt" "$line"	
		echo "$line"
	fi
	count=$((count+1))

done < "$link_file"
}

convert(){
	for file in *; do
		new_file="$(chext $file $new_format)"
		[ "$?" -ne 0 ] && err "$new_file"
		ffmpeg -i "$file" "$new_file"
	done
}


# Read links and dir from file. Download links to a temp dir.
dl_links

# Convert downloaded content into given format, new_format.
convert

rm -rf "$temp_dir"
