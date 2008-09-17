#!/bin/bash

command="$1"
cmparg=$(echo "$*" | tr -d ' ')

if [ "$cmparg" == "" ]; then
	echo "Usage: @src command -::- Show the source code of a user command"
else
	for flder in user/bash user/php user/ruby user/python; do
		filename="$IIBOT_DIR/scripts/$flder/$cmparg"
		if [ -r "$filename" ]; then
			response=$(cat "$filename" 2>&1)
		fi
	done
	cmpresp=$(echo "$response" | tr -d ' ' | tr -d '\n' | tr -d '\r')
	if [ -z "$cmpresp" ]; then
		response="Script not found"
	fi
	echo "$response"
fi
