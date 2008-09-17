#!/bin/bash
if [ "$1" == "" ]; then
	echo "Usage: @whois www.google.com -::- Returns the Name Servers registered for the specified IP or Hostname"
else
	response=$(whois $1 | grep "Server:" | tail -n 3)
	if [ "$response" == "" ]; then
		response="No Name Servers Found"
	fi;
	echo "$response"
fi;