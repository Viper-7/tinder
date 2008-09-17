#!/bin/bash

command="Commands: "
for parent in builtin by_nick; do
	for folder in `ls $IIBOT_DIR/scripts/$parent/`; do
		for file in $IIBOT_DIR/scripts/$parent/$folder/*; do
			if [ -w "$file" ]; then
				sfile=$(basename $file)
				command="$command@$sfile "
			fi
		done
	done
done
echo "$command"
command="User Commands: "
for folder in `ls $IIBOT_DIR/scripts/user/`; do
	for file in $IIBOT_DIR/scripts/user/$folder/*; do
		if [ -w "$file" ]; then
			sfile=$(basename $file)
			command="$command@$sfile "
		fi
	done
done
echo "$command"
echo "Usage: Type a command to see it's usage"

