pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
-- color-wars
-- by thomas michael wallace

function _init()

end

p={
	r=1,c=0,
	f=0,
 _draw=function(self)
 	spr(1,self.c*8,self.r*8)
 end,
 _move=function(self,cw)
  local d=-1
  if(cw)d=1
		
		if(self.f==0)self.r-=d
		if(self.f==1)self.r+=d
		if(self.f==2)self.c+=d
		if(self.f==3)self.c-=d				    

 	if(self.r==0 and self.c==0)then
 	 if(self.f==0)then
 	  self.f=2
 	  self.c=1
 	 else
 	  self.f=0
 	  self.r=1
 	 end
 	elseif(self.r==0 and self.c==15)then
 	 if(self.f==2)then
 	  self.f=1
 	  self.r=1
 	 else
 	  self.f=2
 	  self.c=14
 	 end 	
 	elseif(self.r==15 and self.c==15)then
 	 if(self.f==1)then
 	 	self.f=3
 	 	self.c=14
 	 else
 	  self.f=1
 	  self.r=14
 	 end
 	elseif(self.r==15 and self.c==0)then
 		if(self.f==3)then
 		 self.f=0
 		 self.r=14
 		else
 		 self.f=3
 		 self.c=1
 		end
 	end
 end
}

i={
 l=nil,--last
 cw=nil,--move-dir
}

function _update()

 local cw=nil  
 local l=nil
	if(btnp(0))then
	 l=0
  if(p.f==2)cw=false
  if(p.f==3)cw=true
	elseif(btnp(1))then
	 l=1
	 if(p.f==2)cw=true
	 if(p.f==3)cw=false
	elseif(btnp(2))then
	 l=2
	 if(p.f==0)cw=true
	 if(p.f==1)cw=false
	elseif(btnp(3))then
	 l=3
	 if(p.f==0)cw=false
	 if(p.f==1)cw=true
	else
	 --l=nil
	end
	
	if(i.l==l and i.cw~=nil)then
	 cw=i.cw
	elseif(l~=nil)then
	 i.l=l
	 i.cw=cw
	end
	
	if(cw~=nil)p:_move(cw)

end

function _draw()
	cls()
	--level
	local d=5
	rect(6,6,128-d,128-d,7)
	d=7
	rect(8,8,128-d,128-d,7)
	--players
	p:_draw()
	spr(2,32,0)
	
	--debug
	print(i.l)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000800008000c00c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000088880000c00c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000088880000cccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000088880000cccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000088880000cccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000088880000cccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000008008000c0000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
