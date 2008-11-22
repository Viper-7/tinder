class Float
	def round_to(x)
		(self * 10**x).round.to_f / 10**x
	end
end

class Integer
	def hrsize
		case
			when self < 1024 ** 2: (self.to_f / 1024).round_to(2).to_s + 'Kb'
			when self < 1024 ** 3: (self.to_f / (1024 ** 2)).round_to(1).to_s + 'Mb'
			when self < 1024 ** 4: (self.to_f / (1024 ** 3)).round.to_s + 'Gb'
			when self < 1024 ** 5: (self.to_f / (1024 ** 4)).round_to(2).to_s + 'Tb'
		end
	end
end

class Dir
	def sizesummary
		folders = {}
		%x"du -sLc #{self.path}/* 2>&1".scan(/^(.+?)\t(?:.+\/)?([^\/\ ]+?)(?: .+?)?$/) {|size,name|
			folders[name] = 0 if !folders[name]
			folders[name] += (size.to_i * 1024)
		}
		return folders
	end
end		

totalsize = 0
Dir.new('/opt/filestore').sizesummary.each{|name,size|
	case name
		when 'Random': next
		when 'total': totalsize = size.hrsize
		else print "#{size.hrsize} of #{name}, "
	end
}
puts "#{totalsize} Total"