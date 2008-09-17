#!/bin/bash
args="$*"
cmparg=$(echo "$*" | tr -d ' ')

if [ "$cmparg" == "" ]; then
	echo "Usage: @php echo \"hi\"; -::- Runs a single line of PHP code and returns the result"
else
	response=$(php -r "set_time_limit(10); $args")
	echo "$response"
fi;

