#!/bin/sh

# POSIX compliant script for downloading content to a directory using youtube-dl.
# Change configuration options to suit your needs. link_file (dl.conf by default) MUST be modified.

# Basic Configuration
link_file="$(dirname "$0")/dl.conf" # full path of file containing the links of the media
# The file's first line should be the directory to which the content is to be downloaded, the rest should be links. See: dl_links function
file_extension="mp3" # downloaded content will be converted into this format
ytdl_opt="-f best" # default parameter passed to youtube-dl
ffmpeg_opt="-i" # default parameter passed to ffmpeg 
lib_file="$(dirname "$0")/util.sh" # No need to change

#Program Info
COPYRIGHT=""
VERSION="1.1"
AUTHOR="Hamza Kerem Mumcu"
USAGE="Usage: $(basename "$0") [-e|--extension FILE_EXTENSION] [-s|--skip-ffmpeg] [--youtube-dl YOUTUBE-DL_OPTION...] [--ffmpeg FFMPEG_OPTION...] 
[-h|--help] [-v|--version]\n"

# Source function library file
. "$lib_file" || { printf "Unable to source $lib_file. Exitting.\n" >&2 && exit 1; }

# Error checking
[ -z "$(which youtube-dl)" ] && err "youtube-dl not in path."
[ -z "$(which ffmpeg)" ] && err "ffmpeg not in path."
[ ! -r "$link_file" ] && err "Unable to read link file."

show_help(){
	printf "$USAGE"
	exit 0
}

show_version(){
	printf "dl.sh $VERSION\n"
	printf "Written by $AUTHOR\n"
	exit 0
}

parse_options(){
	ytdl_opt_bool=1
	ffmpeg_opt_bool=1
	skip_ffmpeg_bool=1
	
	while [ "$#" -gt 0 ]; do
		case "$1" in
  --youtube-dl) ytdl_opt_bool=0; ffmpeg_opt_bool=1; ytdl_opt='';;
	  --ffmpeg) ffmpeg_opt_bool=0; ytdl_opt_bool=1; ffmpeg_opt='';;

		    --) break;;
			 *) 
				# Everything read after --youtube-dl or --ffmpeg is considered an option
				# for the corresponding program. Stop youtube-dl option interpretation by entering --ffmpeg
				# or vice versa. --help, -h, --version and -v should all precede --youtube-dl or --ffmpeg
				# in order for them to be interpreted as options passed to dl.sh
				if [ "$ytdl_opt_bool" -eq 0 ]; then
					ytdl_opt="$ytdl_opt""$1 "; 
				elif [ "$ffmpeg_opt_bool" -eq 0 ]; then
					ffmpeg_opt="$ffmpeg_opt""$1 "; 
				elif [ "X$1" = "X--help" ] || [ "X$1" = "X-h" ]; then 
					show_help
				elif [ "X$1" = "X--version" ] || [ "X$1" = "X-v" ]; then 
					show_version
				elif [ "X$1" = "X-s" ] || [ "X$1" = "X--skip-ffmpeg" ]; then 
					skip_ffmpeg_bool=0	
				elif [ "X$1" = "X-e" ] || [ "X$1" = "X--extension" ]; then 
					file_extension="$2"; shift;
				else
					err "Unknown option '$1'. See '--help'."
				fi;;
		esac
		shift
	done
}

dl_links(){
	count=0
	failed_downloads=''

	while read line; do
		if [ "$count" -eq 0 ]; then
			content_dir="$line"
			[ -d "$content_dir" ] || { mkdir "$content_dir" || err "Unable to make directory $content_dir."; }

			# Download all links to temp directory 
			temp_dir="$(mktemp -d)" || err "Unable to create temporary directory."
			cd "$temp_dir" || err "Unable to cd into temporary directory."
		else
			eval youtube-dl "$ytdl_opt" "$line"	|| failed_downloads="${failed_downloads}$link_file:$count:$line\n"
		fi
		count=$((count+1))

	done < "$link_file"
}

convert(){
	failed_conversions=''

	for file in *; do
		new_file="$(chext "$file" "$file_extension" || err "chext function error.")"
		{ eval ffmpeg "$ffmpeg_opt" \"$file\" \"$new_file\" && rm "$file"; } || failed_conversions="${failed_conversions}$file to $new_file\n"
	done
}

move(){
	mv -v ./* "$content_dir" || err "Unable to move files to $content_dir."
	rmdir "$temp_dir" || printf "Unable to remove directory $temp_dir.\n"
}

print_failed(){
	[ -n "$failed_downloads" ] && printf "\nFailed Downloads\n$failed_downloads"
	[ -n "$failed_conversions" ] && printf "\nFailed Conversions\n$failed_conversions"
}

# Parse pos-params
parse_options "$@"

# Read links and dir from file. Download links to a temp dir.
dl_links

# Convert downloaded content into given format, file_extension.
[ "$skip_ffmpeg_bool" -eq 1 ] && convert

# Move files in temp dir to content_dir
move

# Print failed downloads and conversions
print_failed

exit 0
