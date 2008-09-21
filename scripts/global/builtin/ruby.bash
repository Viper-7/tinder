#!/bin/bash

args="$*"
cmparg=$(echo "$*" | tr -d ' ')

if [ "$cmparg" == "" ]; then
	echo "Usage: @ruby puts 'hi' -::- Run a single line of Ruby code"

else
	response=$(echo $args | exec -c ruby 2>&1)
	echo "$response"
fi;

