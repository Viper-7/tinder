#!/bin/bash

args="$*"
cmparg=$(echo "$*" | tr -d ' ')

if [ "$cmparg" == "" ]; then
	echo "Usage: @ruby puts 'hi' -::- Run a single line of Ruby code"

else
	args=$(echo "$args" | awk '{print $1 " " $2 " " $3 " " $4 " " $5 " " $6 " " $7 " " $8 " " $9 " " $10 " " $11 " " $12 " " $13 " " $14 " " $15 " " $16 " " $17 " " $18 " " $19 " " $20 " " $21 " " $22 " " $23 " " $24 " " $25 " " $26 " " $27 " " $28 " " $29 " " $30 " " $31 " " $32 " " $33 " " $34 " " $35 " " $36 " " $37 " " $38 " " $39 " " $40}')
	response=$(echo "$args" | exec -c ruby 2>&1)
	echo "$response"
fi;

