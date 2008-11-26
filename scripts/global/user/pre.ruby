#!/usr/bin/ruby

require 'open-uri'
require 'timeout'

def checkPre(rls)
	output = ""
	begin
		timeout(15) do
			rls3 = rls.gsub(/ 720[pP]?/,'')
			puts "http://scnsrc.net/pre/bots.php?user=betauser38&pass=ye9893V&results=5&search=" + rls3.split(' ').join('.')
			puts open("http://scnsrc.net/pre/bots.php?user=betauser38&pass=ye9893V&results=5&search=" + rls3.split(' ').join('.')).read
		end
	rescue
	end
end

checkPre($*)
