#!/bin/bash
args="$*"
cmparg=$(echo "$*" | tr -d ' ')

if [ "$cmparg" == "" ]; then
	echo "Usage: @txt2ft Hello World! -::- Encodes the specified string in BrainFuck"
else
	args=$(echo "$args" | awk '{print $1 " " $2 " " $3 " " $4 " " $5 " " $6 " " $7 " " $8 " " $9 " " $10 " " $11 " " $12 " " $13 " " $14 " " $15 " " $16 " " $17 " " $18 " " $19 " " $20 " " $21 " " $22 " " $23 " " $24 " " $25 " " $26 " " $27 " " $28 " " $29 " " $30 " " $31 " " $32 " " $33 " " $34 " " $35 " " $36 " " $37 " " $38 " " $39 " " $40}')
	echo "$args" > $IIBOT_TEMP_DIR/bf.log
	$IIBOT_DIR/scripts/tools/ascii2bf $IIBOT_TEMP_DIR/bf.log > /dev/null
	response=$(cat $IIBOT_TEMP_DIR/bf.bf)
	echo $response
fi;

