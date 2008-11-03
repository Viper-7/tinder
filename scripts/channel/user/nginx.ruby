require 'open-uri'

data = open("http://cerberus.viper-7.com/nginx_status").readlines
data[0] =~ /^Active connections: (\d+)/
current_connections = $1
data[2] =~ /^ (\d+) (\d+) (\d+)/
total_connections = $1
successful_connections = $2
failed_connections = (total_connections.to_i - successful_connections.to_i).to_s
total_requests = $3
completion = ((successful_connections.to_i / total_connections.to_i) * 100).to_s
data[3] =~ /^Reading: (\d+) Writing: (\d+) Waiting: (\d+)/
current_reading = $1
current_writing = $2
current_waiting = $3

puts "Nginx Status: #{current_connections} Active connections - #{current_reading} Reading, #{current_writing} Writing, #{current_waiting} Waiting"
puts "#{total_connections} connections since restart - #{failed_connections} failed (#{completion}%). #{total_requests} files served"
