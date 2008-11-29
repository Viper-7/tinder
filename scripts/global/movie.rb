class Movie
	attr_accessor :mysql, :imdbid, :filename, :title, :name, :plot, :imdburl, :tagline, :releasedate
	attr_accessor :rating, :boxurl, :parts, :duration
	
	def self.connect
		if !@mysql
			@mysql = Mysql.init()
			@mysql.connect('cerberus','db','db')
			@mysql.select_db('viper7')
		end
		return @mysql
	end
	
	def cache
		@mysql = Movie.connect
		
		if @imdbid
			qry = @mysql.query("SELECT imdb.ID, Name, Title, Plot, IMDBURL, Tagline, ReleaseDate, Rating, BoxURL, sum(imdbfiles.duration) as duration, max(part) as parts FROM imdb, imdbfiles WHERE imdb.ID=imdbfiles.imdbid AND imdb.ID=#{@imdbid} GROUP BY imdb.id")
			qry.each_hash{|row|
				@name = row['Name'] if !@name
				@title = row['Title'] if !@title
				@plot = row['Plot'] if !@plot
				@imdburl = row['IMDBURL'] if !@imdburl
				@tagline = row['Tagline'] if !@tagline
				@releasedate = row['ReleaseDate'] if !@rating
				@rating = row['Rating'] if !@name
				@boxurl = row['BoxURL'] if !@boxurl
				if row['parts'].to_i > 0 and !@parts
					@parts = row['parts'].to_i
				else
					@parts = 1
				end
				@duration = row['duration'] if !@duration
			}
		else
			puts 'Tried to cache unloaded object'
		end
	end
	
	def save
		@mysql = Movie.connect
		cache
		
		if @imdbid
			@mysql.query("UPDATE imdb SET Name='#{Mysql.escape_string(@name)}', Title='#{Mysql.escape_string(@title)}', Plot='#{Mysql.escape_string(@plot)}', IMDBURL='#{Mysql.escape_string(@imdburl)}', Tagline='#{Mysql.escape_string(@tagline)}', ReleaseDate=#{@releasedate}, Rating='#{@rating}', BoxURL='#{Mysql.escape_string(@boxurl)}' WHERE ID=#{@imdbid}")
		else
			puts 'Tried to save unloaded object'
		end
	end
	
	def self.fetch_by_id(id)
		@mysql = self.connect
		
		qry = @mysql.query("SELECT imdbid, filename FROM imdbfiles WHERE imdbid=#{id}")
		out = []
		qry.each{|id,filename|
			newMovie = Movie.new
			newMovie.imdbid = id
			newMovie.mysql = @mysql
			newMovie.filename = filename
			out.push newMovie
		}
		if out.length == 1
			return out.first 
		else
			return out
		end
	end
	
	def self.fetch_by_name(args)
		@mysql = self.connect
		args = Mysql.escape_string(args)
		qry = @mysql.query("SELECT imdb.ID, filename FROM imdb, imdbfiles WHERE imdb.id = imdbfiles.imdbid AND imdb.Name LIKE '#{args}'")
		out = []
		qry.each{|id,filename|
			newMovie = Movie.new
			newMovie.imdbid = id
			newMovie.mysql = @mysql
			newMovie.filename = filename
			out.push newMovie
		}
		if out.length == 1
			return out.first 
		else
			return out
		end
	end
	
	def self.fetch_by_filename(args)
		@mysql = self.connect
		args = Mysql.escape_string(args)
		qry = @mysql.query("SELECT DISTINCT imdbid, filename FROM imdbfiles WHERE filename LIKE '#{args}'")
		out = []
		qry.each{|id,filename|
			newMovie = Movie.new
			newMovie.imdbid = id
			newMovie.mysql = @mysql
			newMovie.filename = filename
			out.push newMovie
		}
		if out.length == 1
			return out.first 
		else
			return out
		end
	end
	
	def self.fetch_by_sql(sql)
		@mysql = self.connect
		testqry = @mysql.query(sql)
		if testqry.num_fields == 1 and testqry.num_rows > 0
			if testqry.fetch_row[0].match(/\d/)
				qry = @mysql.query("SELECT DISTINCT imdbid, filename FROM imdbfiles WHERE imdbid IN (#{sql})")
				out = []
				qry.each{|id,filename|
					newMovie = Movie.new
					newMovie.imdbid = id
					newMovie.mysql = @mysql
					newMovie.filename = filename
					out.push newMovie
				}
				if out.length == 1
					return out.first 
				else
					return out
				end
			else
				return []
			end
		else
			return []
		end
	end
	
	def self.fetch_all
		@mysql = self.connect
		qry = @mysql.query("SELECT imdbid, filename FROM imdbfiles")
		out = []
		qry.each{|id,filename|
			newMovie = Movie.new
			newMovie.imdbid = id
			newMovie.mysql = @mysql
			newMovie.filename = filename
			out.push newMovie
		}
		if out.length == 1
			return out.first 
		else
			return out
		end
	end
	
	def length
		return 1
	end
	
	def each
		yield self
	end
	
	def delete
		@mysql.query("DELETE FROM imdbfiles WHERE imdbid='#{@imdbid}'")
		@mysql.query("DELETE FROM imdbtags WHERE imdbid='#{@imdbid}'")
		@mysql.query("DELETE FROM imdb WHERE id='#{@imdbid}'")
	end
	
	def self.clear
		@mysql = self.connect
		@mysql.query("TRUNCATE TABLE imdbfiles")
		@mysql.query("TRUNCATE TABLE imdbtags")
		@mysql.query("TRUNCATE TABLE imdb")
	end	
end
