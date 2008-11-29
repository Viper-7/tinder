require 'movie.rb'

newMovie = Movie.fetch_by_name('%' + $*.map{|x| x.gsub!(/and|&|or|of|the|!|'/,'').chomp!}.join('%') + '%')
if newMovie.nil?
	puts 'No Match :('
else
	newMovie.cache
	puts "#{newMovie.name} - http://www.viper-7.com/flv/?imdbid=#{newMovie.imdbid}"
end
