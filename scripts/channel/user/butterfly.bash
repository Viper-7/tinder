#!/bin/bash

curtime=$(date | awk "{ string=\$4; split(string, a, \":\"); print a[1] a[2] int(a[3]/20)}")
if [ -a /tmp/lastbutterfly ]; then
        lastbutterfly=$(cat /tmp/lastbutterfly);
fi
if [ $lastbutterfly -eq $curtime ]; then
        exit
else
        echo "$curtime" > /tmp/lastbutterfly
fi

echo "I met a butterfly the other day."
echo "I was just hanging out in the backyard, about to mow the lawn, when a monarch butterfly flew over and landed on my finger."
echo "I asked him what he wanted."
echo "And he said:"
echo "^B\"Bring back 80's speed metal.\"^B"
echo "I truely feel like I was visited by an angel that day."
