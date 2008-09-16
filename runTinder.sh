#!/bin/bash
while true; do
	ruby ./tinderclient.rb kodiak.viper-7.com
	if [ $? -ne 1 ]; then
		break 2
	fi
done
