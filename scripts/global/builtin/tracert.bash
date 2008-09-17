#!/bin/bash
host="$1"
if [ "$host" == "" ]; then
	echo "Usage: @tracert www.google.com -::- Max hops=11"
else
	traceroute $host -m 11 > $IIBOT_TEMP_DIR/tr.log
	cat $IIBOT_TEMP_DIR/tr.log | tail -n 8
fi;
