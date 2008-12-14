i=0;l=[];d=[];p=0;c=0
e=%w(< > + - . , [ ])
f=%w(p-=1 p+=1 d[p]+=1 d[p]-=1 $><<d[p].chr d[p]=a[c]?a[c]:0;c+=1 d[p]>0?l<<i:\ i=b[i..-1].index(']') d[p]>0?i=l.last:\ l.pop)
?z*?z.times{d<<0}
x=$<.read.match(/^([<>+-\.\,\[\]\s]*)(.*?)$/m)
b=x[1].gsub(/\s/m,'')
a=x[2].unpack('C*')
while i<b.length
com = f[e.index(b[i].chr)]
eval(com)
i+=1;end
