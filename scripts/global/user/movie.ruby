require 'mysql'
require 'movie.rb'

newMovie = Movie.fetch_by_name('%' + $*.join(' ').chomp + '%')
if newMovie != nil
	newMovie.cache
	puts "#{newMovie.name} - http://www.viper-7.com/flv/?imdbid=#{newMovie.imdbid}"
else
	puts 'No Match'
end
