#!/bin/bash

echo -n "$*? "
number=$RANDOM
let "number %= 6"
if [ $number -eq 0 ]; then echo "Yes"; fi
if [ $number -eq 1 ]; then echo "No Wai!"; fi
if [ $number -eq 2 ]; then echo "Maybe"; fi
if [ $number -eq 3 ]; then echo "Ask again later"; fi
if [ $number -eq 4 ]; then echo "For Sure!"; fi
if [ $number -eq 5 ]; then echo "Are you kidding?!?"; fi


