load 'tinderserver.rb'

@tinderClient = TinderClient.new

while true
	begin
		DRb.start_service("druby://:7777", @tinderClient)
		puts DRb.uri
		DRb.thread.join
		load 'tinderserver.rb'
	rescue Exception => ex
		puts ex
		break
	end
end