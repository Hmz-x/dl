#!/bin/sh

# POSIX compliant script for downloading content to a directory using youtube-dl.
# Change configuration options to suit your needs. config_file ($HOME/.dl.conf by default) MUST be modified.

# Basic Configuration
config_file="$HOME/.dl.conf" # full path of file containing the links of the media
# The file's first line should be the directory to which the content is to be downloaded, the rest should be links. See: dl_links function
file_extension="mp4" # default extension; downloaded content will be converted into this format
ytdl_opt="-f best" # default parameter passed to youtube-dl
ffmpeg_opt="-i" # default parameter passed to ffmpeg 

#Program Info
LICENSE="GNU GPLv3"
VERSION="1.1"
AUTHOR="Hamza Kerem Mumcu <hamzamumcu@protonmail.com>"
USAGE="Usage: $(basename "$0") [-e|--extension FILE_EXTENSION] [-s|--skip-ffmpeg] 
[--youtube-dl YOUTUBE-DL_OPTION...] [--ffmpeg FFMPEG_OPTION...] [-h|--help] [-v|--version]"

err(){
	# Print error message, "$1", to stderr and exit.
	printf "%s Exitting.\n" "$1" >&2
	exit 1
}

chext(){
	# Print passed filename, "$1", with its extension removed.
	# Display the filename with its new extension, "$2", instead.

	file="$1"
	[ -z "$file" ] && printf "No filename given. Returning.\n" && return 1
	
	strlen="${#file}"
	dot_index=-1
	i=$((strlen-1))
	
	# Get dot index
	while [ "$i" -gt -1 ]; do
		char="$(printf "%s" "$file" | cut -b $((i+1)))"
		[ "$char" = '.' ] && dot_index="$i" && break
		i=$((i-1))
	done
	
	[ "$dot_index" -eq -1 ] && printf "No extension was detected. Returning.\n" && return 1

	i=0
	# Display filename without extension
	while [ "$i" -lt "$dot_index" ]; do
		char="$(printf "%s" "$file" | cut -b $((i+1)))"
		printf "%s" "$char"
		i=$((i+1))
	done
	
	# Add on new extension	
	[ -n "$2" ] && printf ".%s" "$2"
}

show_help(){
	printf "%s\n" "$USAGE"
	exit 0
}

show_version(){
	printf "dl.sh %s\n" "$VERSION"
	printf "Licensed under %s\n" "$LICENSE"
	printf "Written by %s\n" "$AUTHOR"
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

	while read -r line; do
		if [ "$count" -eq 0 ]; then
			eval content_dir="$line"
			[ -d "$content_dir" ] || { mkdir -p "$content_dir" || err "Unable to make directory $content_dir."; }

			# Download all links to temp directory 
			temp_dir="$(mktemp -d)" || err "Unable to create temporary directory."
			cd "$temp_dir" || err "Unable to cd into temporary directory."
		else
			eval youtube-dl "$ytdl_opt" "$line"	|| failed_downloads="${failed_downloads}$config_file:$count:$line\n"
		fi
		count=$((count+1))

	done < "$config_file"
}

convert(){
	failed_conversions=''

	for file in *; do
		# Get $new_file, which is $file with its extension replaced, if the two strings are equal,
	    # continue on to the next iteration. If not, convert via ffmpeg and then remove original file.
		
		{ new_file="$(chext "$file" "$file_extension")" && 
		{ [ "$new_file" != "$file" ] || continue; } && 
		eval "ffmpeg ""$ffmpeg_opt"" \"$file\" \"$new_file\"" && rm "$file"; } || failed_conversions="${failed_conversions}$file to $new_file\n"
	done
}

move(){
	mv -v ./* "$content_dir" || err "Unable to move files to $content_dir."
	rmdir "$temp_dir" || printf "Unable to remove directory %s.\n" "$temp_dir"
}

print_failed(){
	[ -n "$failed_downloads" ] && printf "\nFailed Downloads\n%s" "$failed_downloads"
	[ -n "$failed_conversions" ] && printf "\nFailed Conversions\n%s" "$failed_conversions"
}

# Error checking
[ -z "$(which youtube-dl)" ] && err "youtube-dl not in path."
[ -z "$(which ffmpeg)" ] && err "ffmpeg not in path."
[ ! -r "$config_file" ] && err "Unable to read configuration file $config_file. Please create it if it doesn't already exist. See:README.md."

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
