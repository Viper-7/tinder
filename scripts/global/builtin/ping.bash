#!/bin/bash
if [ "$1" == "" ]; then
	echo "Usage: @ping www.google.com"
else
	ping $1 -c 5 2>&1 | tail -n 3
fi;
