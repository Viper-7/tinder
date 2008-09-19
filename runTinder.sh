#!/bin/bash
while true; do
	ruby ./tinderChannelBase.rb kodiak.viper-7.com
	if [ $? -ne 1 ]; then
		break 2
	fi
done
