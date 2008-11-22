class Numeric
	def hr_bytes
		case
			when self < 1024 ** 2: "%.2fKb" % (self.to_f / 1024)
			when self < 1024 ** 3: "%dMb" % (self / (1024 ** 2))
			when self < 1024 ** 4: "%dGb" % (self / (1024 ** 3))
			when self < 1024 ** 5: "%.2fTb" % (self.to_f / (1024 ** 4))
		end
	end
end

class Dir
	def size_summary
		folders = {}
		%x"du -sLc #{self.path}/*".scan(/^(.+?)\t(?:.+\/)?(\w+)/) {|size,name|
			folders[name] = 0 if !folders[name]
			folders[name] += (size.to_i * 1024)
		}
		return folders
	end
end

totalsize = 0
Dir.new('/opt/filestore').size_summary.each{|name,size|
	case name
		when 'Random': next
		when 'total': totalsize = size.hr_bytes
		else print "#{size.hr_bytes} of #{name}, "
	end
}
puts "#{totalsize} Total"
