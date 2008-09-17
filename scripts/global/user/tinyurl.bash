#!/bin/bash
if [ "$1" == "" ]; then
	echo "Usage: @tinyurl http://www.google.com/?s=SjhaskiuKJAHdfgdf&highlight=76sd765sdf"
else
	response=$(lynx -dump http://tinyurl.viper-7.com/?url=$1)
	if [ "$response" == "" ]; then
		response="Something broke... And I ain't even gonna guess what.."
	fi;
	echo $response
fi;