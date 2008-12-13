#!/bin/bash

curtime=$(date | awk "{ string=\$4; split(string, a, \":\"); print a[1] a[2]}")
lastbutterfly=0
if [ -a /tmp/lastbutterfly ]; then
        lastbutterfly=$(cat /tmp/lastbutterfly);
fi
if [ $lastbutterfly -eq $curtime ]; then
        exit
else
        echo "$curtime" > /tmp/lastbutterfly
fi
echo "I met a butterfly the other day.<BR>"
echo "I was just hanging out in the backyard, about to mow the lawn, when a monarch butterfly flew over and landed on my finger.<BR>"
echo "I asked him what he wanted.<BR>"
echo "And he said:<BR>"
echo "<B>\"Bring back 80's speed metal.\"</B><BR>"
echo "I truely feel like I was visited by an angel that day. \\m/<BR>"
