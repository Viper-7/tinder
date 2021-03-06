#!/usr/bin/ruby

require 'open-uri'
require 'timeout'

def checkPre(rls)
	output = ""
	begin
		timeout(15) do
			rls3 = rls.gsub(/720[pP]?/,'').chomp
			open("http://scnsrc.net/pre/bots.php?user=betauser38&pass=ye9893V&results=3&search=" + rls3.split(' ').join('.')).read.scan(/([^^]*)\^([^^]*)\^([^^]*)\^\^/){|rlstime,name,type|
				rlstime = rlstime.split("\n").join("")
				name = name.gsub(/[_\.]/,' ')
				if rls.match(/720[pP]?$/)
					next if !name.match(/720/)
					puts "#{type}: #{name} was released #{rlstime.chomp} ago"
				else
					puts "#{type}: #{name} was released #{rlstime.chomp} ago"
				end
			}
		end
	rescue Exception => ex
		puts ex
		puts ex.backtrace
	end
end

checkPre($*.join(' '))
