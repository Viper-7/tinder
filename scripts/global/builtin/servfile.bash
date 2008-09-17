#!/bin/bash

args="$*"
cmparg=$(echo "$*" | tr -d ' ')

if [ "$cmparg" == "" ]; then
	echo "Usage: @servfile http://www.yoururl.com/image.jpg -::- Uploads a file (any type) to a Google filestore"
	echo "Max Size = 1MB! Try to upload bigger = BANT4LYF!"
else
	name=$(basename "$args")
	if [ -a /mnt/thorc/Program\ Files/Google/google_appengine/v7tinyurl/files/$name ]; then
		rm /mnt/thorc/Program\ Files/Google/google_appengine/v7tinyurl/files/$name
	fi;
	wget $args -q -O /mnt/thorc/Program\ Files/Google/google_appengine/v7tinyurl/files/$name
	out=$(cat /var/v7 | /mnt/thorc/Program\ Files/Google/google_appengine/appcfg.py -e viper7@gmail.com --passin update /mnt/thorc/Program\ Files/Google/google_appengine/v7tinyurl 2> /dev/null)
	if [ "$out" != "" ]; then
		echo "http://tinyurl.viper-7.com/files/$name"
	else
		echo "Failed :\("
	fi;
	
fi;