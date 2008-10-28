require 'open-uri'

open("http://www.viper-7.com/flv/").each_line { |line| 
	line.scan(/<TITLE>(.*?) \(.* Quality FLV\)<\/TITLE>/) { |a|
		puts a + ' - http://viper-7.com/flv';
	}
}
