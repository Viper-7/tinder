#!/bin/bash
echo `lynx -dump http://www.whatismyip.com.au | grep Your | cut -f 2 -d :`- | tr -d '-'
