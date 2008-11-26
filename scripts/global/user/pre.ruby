#!/usr/bin/ruby

require 'open-uri'
require 'timeout'

def checkPre(rls)
	puts rls
	output = ""
	begin
		timeout(15) do
			rls3 = rls.gsub(/ 720[pP]?/,'')
			open("http://scnsrc.net/pre/bots.php?user=betauser38&pass=ye9893V&results=5&search=" + rls3.split(' ').join('.')).read.scan(/([^^]*)\^([^^]*)\^([^^]*)\^\^/){|rlstime,name,type|
				rlstime = rlstime.split("\n").join("")
				name = name.gsub(/[_\.]/,' ')
				if rls.match(/720[pP]?$/)
					rls2 = rls.gsub(/ /,'.+')
					if name.match(/720/)
						puts "#{type}: #{name} was released #{rlstime.chomp} ago"
					end
				else
					rls2 = rls.gsub(/ /,'.+')
					puts "#{type}: #{name} was released #{rlstime.chomp} ago"
				end
			}
		end
	rescue
	end
end

checkPre($*)
