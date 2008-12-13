echo -n "Plain Text: Ruby"
ab -n 120 -c 8 http://viper-7.com/tinder/text/benchruby | grep "Requests per second" | cut -d ':' -f 2
echo -n "Plain Text: PHP"
ab -n 120 -c 8 http://viper-7.com/tinder/text/benchphp | grep "Requests per second" | cut -d ':' -f 2
echo -n "Plain Text: Perl"
ab -n 120 -c 8 http://viper-7.com/tinder/text/benchperl | grep "Requests per second" | cut -d ':' -f 2
echo -n "Plain Text: Python"
ab -n 120 -c 8 http://viper-7.com/tinder/text/benchpython | grep "Requests per second" | cut -d ':' -f 2
echo -n "Plain Text: Tcl"
ab -n 120 -c 8 http://viper-7.com/tinder/text/benchtcl | grep "Requests per second" | cut -d ':' -f 2
echo -n "Plain Text: Bash"
ab -n 120 -c 8 http://viper-7.com/tinder/text/benchbash | grep "Requests per second" | cut -d ':' -f 2

echo -n "JSON: Python"
ab -n 120 -c 8 http://viper-7.com/tinder/json/benchpython | grep "Requests per second" | cut -d ':' -f 2
echo -n "XML: Python"
ab -n 120 -c 8 http://viper-7.com/tinder/xml/benchpython | grep "Requests per second" | cut -d ':' -f 2
echo -n "SOAP: Python"
ab -n 120 -c 8 http://viper-7.com/tinder/soap/benchpython | grep "Requests per second" | cut -d ':' -f 2
echo -n "HTML: Python"
ab -n 120 -c 8 http://viper-7.com/tinder/benchpython | grep "Requests per second" | cut -d ':' -f 2

echo -n "JSON: PHP"
ab -n 120 -c 8 http://viper-7.com/tinder/json/benchphp | grep "Requests per second" | cut -d ':' -f 2
echo -n "SOAP: Ruby"
ab -n 120 -c 8 http://viper-7.com/tinder/soap/benchruby | grep "Requests per second" | cut -d ':' -f 2
