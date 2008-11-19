load 'tinderServerBase.rb'

@tinderServer = TinderServer.new if !@tinderServer

@bots = []

while true
	begin
		port = 7777
		10.times do
			@bots.push DRb.new("druby://:#{port}", @tinderServer)
			puts @bots.last.uri
			port += 1
		end
		@bots.first.thread.join
	rescue Exception => ex
		puts ex
		break
	end
end

