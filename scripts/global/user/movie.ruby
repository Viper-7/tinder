require 'movie.rb'

newMovie = Movie.fetch_by_name('%' + $*.join(' ').gsub(/\s*(?:and|&|or|of|the|!|')\s*/,'').gsub(/ /,'%') + '%').first
if newMovie.nil?
	puts 'No Match :('
else
	newMovie.cache
	puts "#{newMovie.name} - http://www.viper-7.com/flv/?imdbid=#{newMovie.imdbid}"
end
