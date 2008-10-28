require 'open-uri'

open("http://cerberus.viper-7.com/flv/").each_line { |line| 
	out = '';
	line.scan(/<TITLE>(.*?) \((.*) Quality FLV\)<\/TITLE>/) { |a|
		out = a[0] + ' - ' + a[1] + ' Quality FLV - ';
	}
	line.scan(/<CENTER><A HREF="(.*?)">Direct Link<\/A>/) { |b|
		out = out + b[0];
	}
}
puts out;
