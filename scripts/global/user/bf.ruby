i=0;l=[];d=[];p=0;c=0
99999.times {|x| d[x]=0}
x=$*.join.match(/^((?:[+-<>\[\].,]*\s*)*)(.*?)$/m)
a=x[2].unpack('C*')
x=x[1].gsub(/\s/m,'')
while i<x.length
case x[i]
when '<';p-=1
when '>';p+=1
when '+';d[p]+=1
when '-';d[p]-=1
when '.';print d[p].chr
when ',';d[p]=a[c]?a[c]:0;c+=1
when '[';l.push i
when ']';d[p]>0?i=l.last: l.pop
end;i+=1;end
