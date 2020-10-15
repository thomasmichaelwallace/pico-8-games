pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
roots={}
ends={}
score=0

ani={
 t=0,--timer
 a=false,--animation frame
 r=4,--animation rate
 o=0,--offset
}

function add_domino(x,y,v)
	local d={
		x=x,--screen x
	 y=y,--map y
	 s=1,--tl sprite id
	 n={},--next dominos
	 f=false,--falling
	 v=1+flr(rnd(6-1+1)),
	 draw=function(self)
	  for n in all(self.n) do
	   n:draw()
	  end
	  local y=(128-8)-(self.y*8)+ani.o
	 	spr(self.s,self.x,y,1,2)
	 	spr(self.v+4,self.x,y-(self.s-1),1,2)
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
	 	self.f=true
	 	score+=self.v
	 end,
	 fwd=function(self,c)
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
	 walk=function(self)
	  self.y-=1
	  --end of line
	  if(#self.n==0 and self.y==16)then
	   local c=1
	   if(rnd(10)>9)c=2
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
	   n:walk()
	  end
	  
	  --start of line
	  if(self.y==-1)then
	 	 return self.n
	 	end
	 	return {self}
	 end
	}
	return d
end

function _init()
 --printh("start")
 palt(0,false)
 palt(14,true)
 --for n=1,1,1 do
 local n=2
 local r=add_domino(32*n-8,8)
 local d=r
 for y=0,8,1 do
  d=(d:fwd(1))[1]
 end
 r:fall()
 add(roots,r)
 --end
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
   local ws=r:walk()
   for w in all(ws) do
    add(nr,w)
   end
  end
  roots=nr
 end
 
 for r in all(roots) do
  r:update()
 end
end

function _draw()
 cls(1)
 for r in all(roots) do
  r:draw()
 end
 print(score)
end
__gfx__
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeee777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
00700700eeeeeeeeeeeeeeeee766667ee766667eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
00077000eeeeeeeee777777ee777777ee776667eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
00077000e777777ee766667ee776767ee767667eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
00700700e766667ee777777ee766677ee776767eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
00000000e777777ee777767ee776767ee777677eeeeeeeeeeeeeeeeeeee05eeeeeeeeeeeee0505eeee0505ee0000000000000000000000000000000000000000
00000000e777777ee777677ee767677ee777767eeeeeeeeeeee05eeeeee00eeeee0505eeee0000eeee0000ee0000000000000000000000000000000000000000
00000000e777767ee776767ee776777ee777777eeeeeeeeeeee00eeeeeeeeeeeee0000eeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
00000000e777677ee767677ee767777ee777777eeee05eeeeeeeeeeeeee05eeeeeeeeeeeeee05eeeee0505ee0000000000000000000000000000000000000000
00000000e776767ee776667ee777777ee766667eeee00eeeeeeeeeeeeee00eeeeeeeeeeeeee00eeeee0000ee0000000000000000000000000000000000000000
00000000e767667ee767677ee766667ee777777eeeeeeeeeeee05eeeeeeeeeeeee0505eeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
00000000e776667ee777777ee777777eeeeeeeeeeeeeeeeeeee00eeeeee05eeeee0000eeee0505eeee0505ee0000000000000000000000000000000000000000
00000000e766667ee766667eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00eeeeeeeeeeeee0000eeee0000ee0000000000000000000000000000000000000000
00000000e777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0000000000000000000000000000000000000000
