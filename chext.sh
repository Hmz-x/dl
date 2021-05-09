#!/bin/sh

chext(){
	
	# Print passed filename "$1", with its extension removed.
	# 

	file="$1"
	[[ -z "$file" ]] && printf "No filename given. Exitting\n" >&2 && return 1
	
	strlen="${#file}"
	dot_index=-1
	i=$(($strlen-1))
	
	# Get dot index
	while [ "$i" -gt -1 ]; do
		char="$(printf "$file" | cut -b $((i+1)))"
		[ "$char" = '.' ] && dot_index="$i" && break
		i=$(($i-1))
	done
	
	[ "$dot_index" -eq -1 ] && printf "No extension was detected. Exitting\n" >&2 && return 1
	
	i=0
	# Display filename without extension
	while [ "$i" -lt "$dot_index" ]; do
		char="$(printf "$file" | cut -b $((i+1)))"
		printf "$char"
		i=$(($i+1))
	done
	
	# Add on new extension	
	printf ".$2"
}
