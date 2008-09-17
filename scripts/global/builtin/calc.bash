#!/bin/bash

args="$*"
cmparg=$(echo "$*" | tr -d ' ')

if [ "$cmparg" == "" ]; then
	echo "Usage: @calc 12 + 56 -::- Use PHP to calculate a number"
	echo "Use x to multiply, / to divide. PHP code is supported."
else

	echo "$args"
	response=$(exec -c php -r "echo $args;")
	echo $response
fi;

