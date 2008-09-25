#!/bin/bash

CHAN="$2"
outfile="$IIBOT_DIR/scripts/user/$3/$4"
nick="$1"
lang=$(echo "$3" | tr "[:upper:]" "[:lower:]")
user=$(echo "$1" | tr "[:upper:]" "[:lower:]")
cmparg=$(echo "$3" | tr -d ' ')

if [ "$cmparg" == "" ]; then
	echo "Usage: @makescript <language> <command> -::- Starts a private message session with you, and captures your text into a script named <command>"
else
	if [ -d "$IIBOT_DIR/scripts/user/$3" ]; then
		if [ "$user" == "viper-7" ]; then
			:>$outfile
			:>$IIBOT_IIFS_SERVER_DIR/$user/out

			#	Headers
			if [ "$lang" == "bash" ]; then
				echo '#!/bin/bash' > $outfile
			elif  [ "$lang" == "php" ]; then
				echo '#!/usr/bin/php' > $outfile
				echo '<?php' > $outfile
			elif  [ "$lang" == "ruby" ]; then
				echo '#!/usr/bin/ruby' > $outfile
			elif  [ "$lang" == "python" ]; then
				echo '#!/usr/bin/python' > $outfile
			fi

			echo "/PRIVMSG $nick :Now capturing from $user to $4. End with # on a blank line" >> $IIBOT_IIFS_SERVER_DIR/in
			
			tail -n 1 -f $IIBOT_IIFS_SERVER_DIR/$user/out | while read sline
			do
				name=$(echo "$sline" | cut -f 3 -d ' ' | sed 's,<\(.*\)>,\1,')
				cmd=$(echo "$sline" | cut -f 4 -d ' ')
				char=${cmd:0:1}
				cmd=${cmd:1}
				text=$(echo "$sline" | cut -f 4- -d ' ')

				if [ "$char" == '#' ]; then
					#	Footers
					if  [ "$lang" == "php" ]; then
						echo '?>' >> $outfile
					fi
					echo "Wrote @$4"
					for pid in $(ps axo pid o command | grep tail | grep "n 1 -f" | grep $IIBOT_IIFS_SERVER_DIR/$user/out | awk '{print $1}'); do kill $pid; done
					chmod 755 $outfile
					break;break;
				else
					if [ "$char" != '@' ]; then
						if [ "$nick" == "$name" ]; then
								echo "$text" >> $outfile
						fi
					fi
				fi
			done
		else
			echo "Unauthorized."
		fi
	else
		echo "Unrecognized Language"
	fi
fi
