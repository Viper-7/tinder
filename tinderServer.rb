
load 'tinderServerBase.rb'

@tinderServer = TinderServer.new if !@tinderServer

while true
	begin
		DRb.start_service("druby://:7777", @tinderServer)
		puts DRb.uri
		DRb.thread.join
	rescue Exception => ex
		puts ex
		break
	end
end