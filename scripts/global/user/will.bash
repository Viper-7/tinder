#!/bin/bash
number=$RANDOM
let "number %= 3"
if [ $number -eq 1 ]; then 
	echo "NEG IS GAY! NEG IS GAY! NEG IS GAY! NEG IS GAY! NEG IS GAY! NEG IS GAY! NEG IS GAY! NEG IS GAY! NEG IS GAY! NEG IS GAY!"
else
	echo "NO @WILL!"
fi
