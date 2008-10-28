require 'open-uri'

out = '';
open("http://cerberus.viper-7.com/flv/").each_line { |line| 
	line.scan(/<TITLE>(.*?) \((.*?) Quality FLV\)<\/TITLE>/) { |a|
		out = a[0] + ' - ' + a[1] + ' Quality FLV - ';
	}
	line.scan(/<A HREF="\?ticket(.*?)">Direct Link<\/A>/) { |b|
		out = out + 'http://viper-7.com/flv?ticket' + b[0];
	}
}
puts out;
