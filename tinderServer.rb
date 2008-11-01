
load 'tinderServerBase.rb'

@tinderClient = TinderClient.new if !@tinderClient

while true
	begin
		DRb.start_service("druby://:7777", @tinderClient)
		puts DRb.uri
		DRb.thread.join
	rescue Exception => ex
		puts ex
		break
	end
end