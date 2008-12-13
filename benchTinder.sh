#!/bin/bash

echo "(Interface: Scripting Language   # hits / second)"
echo -n "Plain Text: Ruby		"
ab -n 120 -c 5 http://viper-7.com/tinder/text/benchruby | grep "Requests per second" | cut -d ':' -f 2 | cut -d '[' -f 1
echo -n "Plain Text: PHP		"
ab -n 120 -c 5 http://viper-7.com/tinder/text/benchphp | grep "Requests per second" | cut -d ':' -f 2 | cut -d '[' -f 1
echo -n "Plain Text: Perl		"
ab -n 120 -c 5 http://viper-7.com/tinder/text/benchperl | grep "Requests per second" | cut -d ':' -f 2 | cut -d '[' -f 1
echo -n "Plain Text: Python		"
ab -n 120 -c 5 http://viper-7.com/tinder/text/benchpython | grep "Requests per second" | cut -d ':' -f 2 | cut -d '[' -f 1
echo -n "Plain Text: Tcl		"
ab -n 120 -c 3 http://viper-7.com/tinder/text/benchtcl | grep "Requests per second" | cut -d ':' -f 2 | cut -d '[' -f 1
echo -n "Plain Text: Bash		"
ab -n 120 -c 3 http://viper-7.com/tinder/text/benchbash | grep "Requests per second" | cut -d ':' -f 2 | cut -d '[' -f 1
echo "---"
echo -n "JSON: Ruby		"
ab -n 120 -c 5 http://viper-7.com/tinder/json/benchruby | grep "Requests per second" | cut -d ':' -f 2 | cut -d '[' -f 1
echo -n "JSON: PHP		"
ab -n 120 -c 5 http://viper-7.com/tinder/json/benchphp | grep "Requests per second" | cut -d ':' -f 2 | cut -d '[' -f 1
echo "---"
echo -n "XML: Ruby		"
ab -n 120 -c 5 http://viper-7.com/tinder/xml/benchruby | grep "Requests per second" | cut -d ':' -f 2 | cut -d '[' -f 1
echo -n "SOAP: Ruby		"
ab -n 120 -c 5 http://viper-7.com/tinder/soap/benchruby | grep "Requests per second" | cut -d ':' -f 2 | cut -d '[' -f 1
echo -n "HTML: Ruby		"
ab -n 120 -c 5 http://viper-7.com/tinder/benchruby | grep "Requests per second" | cut -d ':' -f 2 | cut -d '[' -f 1
