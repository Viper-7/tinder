#!/bin/bash

args="$*"
cmparg=$(echo "$*" | tr -d ' ')

if [ "$cmparg" == "" ]; then
	echo "Usage: @ruby puts 'hi' -::- Run a single line of Ruby code"

else
	response=$(ruby -e "$args" 2>&1)
	echo "$response"
fi;

