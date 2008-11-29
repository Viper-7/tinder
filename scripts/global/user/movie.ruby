require 'movie.rb'

Movie.connect
newMovie = Movie.fetch_by_name('%' + $*.join(' ').gsub(/(?:and|&|or|of|the|!|')/,'').split(/\s*/).join('%') + '%').first
if newMovie.nil?
	puts 'No Match :('
else
	newMovie.cache
	puts "#{newMovie.name} - http://www.viper-7.com/flv/?imdbid=#{newMovie.imdbid}"
end
