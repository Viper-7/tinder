class Float
  def round_to(x)
    (self * 10**x).round.to_f / 10**x
  end

  def ceil_to(x)
    (self * 10**x).ceil.to_f / 10**x
  end

  def floor_to(x)
    (self * 10**x).floor.to_f / 10**x
  end
end

def hrsize(size)
	return case
		when size < 1024: (size.to_f / 1024).round_to(2).to_s + 'Kb'
		when size < 1024 ** 2: (size.to_f / (1024)).round_to(1).to_s + 'Mb'
		when size < 1024 ** 3: (size.to_f / (1024 ** 2)).round.to_s + 'Gb'
		when size < 1024 ** 4: (size.to_f / (1024 ** 3)).round_to(2).to_s + 'Tb'
	end
end

intext = %x[du -sLc /opt/filestore/* 2>&1]
folders = {}

intext.scan(/^(.+?)\t(.+)$/) {|x,y|
	y.scan(/^(?:.+\/)?([^\/\ ]+)/) {|z|
		if folders[z[0]]
			folders[z[0]] = x.to_i + folders[z[0]]
		else
			folders[z[0]] = x.to_i
		end
	}
}

totalsize=0
folders.each{|name,size|
	next if name == 'Random'
	totalsize = hrsize(size) if name == 'total'
	print "#{hrsize(size)} of #{name}, " if name != 'total'
}
puts "#{totalsize} Total"