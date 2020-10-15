pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
roots={}
ends={}
gaps={}
score=0

ani={
 t=0,--timer
 a=false,--animation frame
 r=8,--animation rate
 o=0,--offset
}

pnt={
 x=64,
 y=64,
}

function add_domino(x,y,g)
	local d={
		x=x,--screen x
	 y=y,--map y
	 s=1,--tl sprite id
	 n={},--next dominos
	 f=false,--falling
	 v=1+flr(rnd(6-1+1)),
	 g=(g or false),-- true if gap
	 k=false,--selected
	 draw=function(self)
	  for n in all(self.n) do
	   n:draw()
	  end
	  local y=(128-8)-(self.y*8)+ani.o
	 	if(self.g)then
	 	 local s=11
	 	 if(self.k)s=12
	 	 spr(s,self.x,y,1,2)
	 	else
	 	 spr(self.s,self.x,y,1,2)
	 	 spr(self.v+4,self.x,y-(self.s-1),1,2)
	  end
	 end,
	 update=function(self)
	  if(not ani.a)return
	 	for n in all(self.n) do
	   n:update()
	  end
	  if(not self.f)return
   if(self.s<4)then
	   self.s+=1
	   if(self.s==3)then
	   	for n in all(self.n) do
		    n:fall()
	    end
	   end
	  end
	 end,
	 fall=function(self)
	  if(self.g)return
	 	self.f=true
	 	score+=self.v
	 	if(score>1000)ani.r=4
	 	if(score>2000)ani.r=2
	 	--if(score>300)ani.r=2
	 end,
	 fwd=function(self,c)
	  if(c==0)then
	   d=add_domino(self.x,self.y+1,true)
	   self.n={d}
	   return self.n
	  end
	  local x=self.x
	 	if(c<=1)then
	 	 x+=rnd(8)-4
	 	else
	 	 x-=((c-1)*8)/2
	 	end
	 	if(x<0)x=0
	 	for i=1,c,1 do
	 	 local d=add_domino(x,self.y+1)
	   x+=8
	   if(x>119)x=119
	   add(self.n,d)
	  end
	  return self.n
	 end,
	 walk=function(self,prop)
	  self.y-=1
	  --end of line
	  if(#self.n==0 and self.y==16 and prop)then
	   local c=1
	   local p=rnd(10)
	   if(p>9)then
	    c=2
	   elseif(p<1)then
	    c=0
	   end
	   --if(c==2)printh("s")
	   local n=self:fwd(c)
	   self.n={}
	   for e in all(n) do
	    --merge
	    local m=false
	    for t in all(ends) do
	     if(e.x>=t.x and e.x<=(t.x+7))then
	      t.x=(e.x+t.x)/2
	      m=true
	     end
	    end
	    --if(m)printh("m")
	    if(not m)then
	     add(self.n,e)
	     add(ends,e)
	    end
	   end
	   return
	  end
	  
	  for n in all(self.n) do
	   n:walk(prop)
	  end
	  
	  --start of line
	  if(self.y==-1)then
	   if(self.g)del(gaps,self)
	 	 return self.n
	 	end
	 	return {self}
	 end,
	 fill=function(self)
	  self.g=false
	  self.k=false
	  del(gaps,self)
	 end
	}
	if(d.g)then
	 add(gaps,d)
	end
	return d
end

function start()
	score=0
	gaps={}
	ani.r=8
 for n=1,1,1 do
	 local n=2
	 local r=add_domino(32*n-8,8)
	 local d=r
	 for y=0,8,1 do
	  d=(d:fwd(1))[1]
	 end
	 r:fall()
	 add(roots,r)
 end
end

function _init()
 --printh("start")
 palt(0,false)
 palt(14,true)
 start()
end

function _update()
 ani.t+=1
 ani.a=ani.t==ani.r
 if(ani.a)then
  ani.t=0
 end
 ani.o+=(4/ani.r)
 
 if(ani.o==8)then
  ani.o=0
  local nr={}
  ends={} --reset
  for r in all(roots) do
   local ws=r:walk(r.f)
   for w in all(ws) do
    add(nr,w)
   end
  end
  roots=nr
 end
 
 for r in all(roots) do
  r:update()
 end

 if(#gaps>0)then
  local i=1
  for gi=1,#gaps,1 do
   if(gaps[gi].k)then
    gaps[gi].k=false
    i=gi
   end
  end
  if(btnp(1))i+=1
  if(btnp(0))i-=1
  if(i<1)i=#gaps
  if(i>#gaps)i=1
  gaps[i].k=true
  
  if(btnp(4)or btnp(5))then
   gaps[i]:fill()
  end
 end
 
 if(#roots==0)then
  if(btnp(4)or btnp(5))then
   --printh("reboot")
   start()
  end
 end
end

function printc(t,y,c)
 print(t,64-#t*2,y,c)
end

function _draw()
 cls(1)
 for r in all(roots) do
  r:draw()
 end
 if(#roots==0)then
  printc("game over",53,13)
  printc(tostr(score),61,9)
  printc("press ❎ to replay",69,13)
 else
  print(score)
 end
end
__gfx__
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeee777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000
00700700eeeeeeeeeeeeeeeee766667ee766667eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000
00077000eeeeeeeee777777ee777777ee776667eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000
00077000e777777ee766667ee776767ee767667eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeededdedee9e99e9e000000000000000000000000
00700700e766667ee777777ee766677ee776767eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeedeeeedee9eeee9e000000000000000000000000
00000000e777777ee777767ee776767ee777677eeeeeeeeeeeeeeeeeeee05eeeeeeeeeeeee0505eeee0505eeeeeeeeeeeeeeeeee000000000000000000000000
00000000e777777ee777677ee767677ee777767eeeeeeeeeeee05eeeeee00eeeee0505eeee0000eeee0000eeedeeeedee9eeee9e000000000000000000000000
eeeeeeeee777767ee776767ee776777ee777777eeeeeeeeeeee00eeeeeeeeeeeee0000eeeeeeeeeeeeeeeeeeedeeeedee9eeee9e000000000000000000000000
eeeeeeeee777677ee767677ee767777ee777777eeee05eeeeeeeeeeeeee05eeeeeeeeeeeeee05eeeee0505eeeeeeeeeeeeeeeeee000000000000000000000000
eee99eeee776767ee776667ee777777ee766667eeee00eeeeeeeeeeeeee00eeeeeeeeeeeeee00eeeee0000eeedeeeedee9eeee9e000000000000000000000000
ee99a9eee767667ee767677ee766667ee777777eeeeeeeeeeee05eeeeeeeeeeeee0505eeeeeeeeeeeeeeeeeeedeeeedee9eeee9e000000000000000000000000
ee9999eee776667ee777777ee777777eeeeeeeeeeeeeeeeeeee00eeeeee05eeeee0000eeee0505eeee0505eeeeeeeeeeeeeeeeee000000000000000000000000
eee99eeee766667ee766667eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeeeee0000eeee0000eeedeeeedee9eeee9e000000000000000000000000
eeeeeeeee777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeededdedee9e99e9e000000000000000000000000
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000
