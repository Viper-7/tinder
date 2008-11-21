load 'tinderServerBase.rb'

@tinderServer = TinderServer.new if !@tinderServer

@bots = []

while true
	begin
		port = 7777
		@bots.push DRb.start_service("druby://:#{port}", @tinderServer)
		puts @bots.last.uri
		@bots.first.thread.join
	rescue Exception => ex
		puts ex
		break
	end
end

