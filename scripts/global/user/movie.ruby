require 'mysql'
require '../movie.rb'

newMovie = Movie.fetch_by_name('%' + $*.join(' ').chomp + '%')
newMovie.cache
puts "#{newMovie.name} - http://www.viper-7.com/flv/?imdbid=#{newMovie.imdbid}"
