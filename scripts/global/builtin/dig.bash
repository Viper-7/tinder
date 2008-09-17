#!/bin/bash
if [ "$1" == "" ]; then
	echo "Usage: @dig www.google.com -::- Returns the Answer Section from a Dig report on the supplied hostname"
else
	response=$(dig $1 | grep "ANSWER SECTION" -A 1 | grep IN | tr '\t' ' ')
	if [ "$response" == "" ]; then
		response="Record not found :("
	fi;
	echo $response
fi;

