require 'time'
instr = "1,hello,world,my,name,is";

start = Time.now.to_f

100000.times do
	tok = instr.index(',')+1
	val = instr[tok,instr.index(',',tok)-tok]
end

puts 'Ruby token: ' + (Time.now.to_f - start).to_s + '<BR>'
start = Time.now.to_f

100000.times do
	val = instr.match(/^.+?,(.+?),/)[1]
end

puts 'Ruby match regex: ' + (Time.now.to_f - start).to_s + '<BR>'
start = Time.now.to_f

100000.times do
	val = instr.split(',')
end

puts 'Ruby split char: ' + (Time.now.to_f - start).to_s + '<BR>'
start = Time.now.to_f

100000.times do
	val = instr.split(/,/)
end

puts 'Ruby split regex: ' + (Time.now.to_f - start).to_s + '<BR>'
