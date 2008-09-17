#!/bin/bash

args="$*"
cmparg=$(echo "$*" | tr -d ' ')

if [ "$cmparg" == "" ]; then
	echo "Usage: @tcl puts hi -::- Run a single line of tcl code"
	
else
	response=$(echo "$args" | tclsh 2>&1)
	echo "$response"
fi;

