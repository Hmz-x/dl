#!/bin/sh

# POSIX compliant script for downloading content to a directory using youtube-dl.
# Change configuration options to suit your needs. link_file's contents MUST be modified.

# Basic Configuration
link_file="$(dirname "$0")/dl.conf" # full path of file containing the links of the media
# The file's first line should be the directory to which the content is to be downloaded, the rest should be links. See: dl_links function
new_format="mp3" # downloaded content will be converted into this format
ytdl_opt="-x" # parameter passed to youtube-dl
lib_file="$(dirname "$0")/util.sh" # No need to change

# Source function library file
. "$lib_file" || { printf "Unable to source $lib_file. Exitting.\n" >&2 && exit 1; }

# Error checking
[ -z "$(which youtube-dl)" ] && err "youtube-dl not in path."
[ -z "$(which ffmpeg)" ] && err "ffmpeg not in path."
[ ! -r "$link_file" ] && err "Unable to read link file."

dl_links(){
	count=0
	while read line; do
		if [ "$count" -eq 0 ]; then
			content_dir="$line"
			[ -d "$content_dir" ] || { mkdir "$content_dir" || err "Unable to make directory $content_dir."; }

			# Download all links to temp directory 
			temp_dir="$(mktemp -d)" || err "Unable to create temporary directory."
			cd "$temp_dir" || err "Unable to cd into temporary directory."
		else
			youtube-dl "$ytdl_opt" "$line"	
		fi
		count=$((count+1))

	done < "$link_file"
}

convert(){
	for file in *; do
		new_file="$(chext "$file" "$new_format" || err "chext function error.")"
		ffmpeg -i "$file" "$new_file"
		rm "$file" || printf "Unable to remove $file.\n"
	done
}

move(){
	mv ./* "$content_dir" || err "Unable to move files to $content_dir."
	rmdir "$temp_dir" || printf "Unable to remove directory $temp_dir.\n"
}

# Read links and dir from file. Download links to a temp dir.
dl_links

# Convert downloaded content into given format, new_format.
convert

# Move files in temp dir to content_dir
move
