require 'open-uri';

data = open($*[0]); 
data.each_line {|line| line.scan(/.*\<title\>(.*)\<\/title\>/) { |a| puts a }}
