require 'time'
instr = "1,hello,world,my,name,is";

start = Time.now.to_f

100000.times do
	val = instr.split(',')
end

puts (Time.now.to_f - start).to_s + '<BR>'
start = Time.now.to_f

100000.times do
	val = instr.split(/,/)
end

puts (Time.now.to_f - start).to_s + '<BR>'
start = Time.now.to_f

100000.times do
	tok = instr.index(',')+1
	val = instr[tok,instr.index(',',tok)-tok]
end

puts (Time.now.to_f - start).to_s + '<BR>'
start = Time.now.to_f

100000.times do
	val = instr.match(/^.+?,(.+?),/)[0]
end

puts (Time.now.to_f - start).to_s + '<BR>'

