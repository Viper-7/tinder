#!/bin/bash

echo -n "$*? <B>"
number=$RANDOM
let "number %= 6"
if [ $number -eq 0 ]; then echo "Yes</B><BR>"; fi
if [ $number -eq 1 ]; then echo "No Wai!</B><BR>"; fi
if [ $number -eq 2 ]; then echo "Maybe</B><BR>"; fi
if [ $number -eq 3 ]; then echo "Ask again later</B><BR>"; fi
if [ $number -eq 4 ]; then echo "For Sure!</B><BR>"; fi
if [ $number -eq 5 ]; then echo "Are you kidding?!?</B><BR>"; fi


