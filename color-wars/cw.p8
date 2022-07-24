pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
-- color-wars
-- by thomas michael wallace

pl={}
en={}

function _init()
 mp:_init()
 pl=_init_player(5,0,true)
 for i=0,1,1 do
  en[i]=_init_player(10,15,false)
 end
end

function _init_player(nrow,ncol,nply)
 local ns=1
 local nl=8
 if(nply)then
  ns=2
  nl=12
 end
 
 local nf=0
 if(ncol==0 )nf=0
 if(ncol==15)nf=1
 if(nrow==0 )nf=2
 if(nrow==15)nf=3
 local np={
	 r=nrow,c=ncol,
	 s=ns,
	 l=nl,
	 f=nf,
  _draw=function(self)
  	spr(self.s,self.c*8,self.r*8)
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
 return np
end

ip={--input
 l=nil,--last
 cw=nil,--move-dir
 t=0,--ticker
}

mp={
 t={},--tiles
 _init=function(self)
  self.t={}
  for r=0,15,1 do
   self.t[r]={}
   for c=0,15,1 do
    local l=0
    if(rnd(10)<1)l=6
    if(r==0 or r==15)l=0
    if(c==0 or c==15)l=0
    self.t[r][c]=l
   end
  end
 end,
 _draw=function(self)
  for r=0,15,1 do
   for c=0,15,1 do
    local x=c*8
    local y=r*8
    local t=self.t[r][c]
    rectfill(x,y,x+8,y+8,t)
   end
  end
 end,
 _shoot=function(self,row,col,dir,clr)
  local dr=0
  local dc=0
  if(dir==0)dc=-1
  if(dir==1)dc=1
  if(dir==2)dr=-1
  if(dir==3)dr=1
  local r=row
  local c=col
  for n=0,15,1 do
   local l=clr
   if(r==0 or r==15)l=0
   if(c==0 or c==15)l=0
   local e=mp.t[r][c]
   if(e~=0 and e~=l)then
    break;
   end
   mp.t[r][c]=l
   r+=dr
   c+=dc
  end
 end
}

function _update()
 --shoot
 if(btnp(4) or btnp(5))then
  local d=0
  for e in all(en) do
   d=e.f+1
   if(e.f==1)d=0
   if(e.f==3)d=2
   mp:_shoot(e.r,e.c,d,e.l)
  end
  d=pl.f+1
  if(pl.f==1)d=0
  if(pl.f==3)d=2
  mp:_shoot(pl.r,pl.c,d,pl.l)
 end

 --rotate
 local cw=nil  
 local l=nil
	if(btn(0))then
	 l=0
	 if(pl.f==0)cw=true
	 if(pl.f==1)cw=false
  if(pl.f==2)cw=false
  if(pl.f==3)cw=true
	elseif(btn(1))then
	 l=1
	 if(pl.f==0)cw=false
	 if(pl.f==1)cw=true
	 if(pl.f==2)cw=true
	 if(pl.f==3)cw=false
	elseif(btn(2))then
	 l=2
	 if(pl.f==0)cw=true
	 if(pl.f==1)cw=false
	 if(pl.f==2)cw=true
	 if(pl.f==3)cw=false
	elseif(btn(3))then
	 l=3
	 if(pl.f==0)cw=false
	 if(pl.f==1)cw=true
	 if(pl.f==2)cw=false
	 if(pl.f==3)cw=true
	else
	 l=nil
	end
	
	if(ip.l==l and ip.cw~=nil)then
	 cw=ip.cw
	else
	 ip.l=l
	 ip.cw=cw
	end
	
	if(cw~=nil)then
	 if(ip.t>0)then
	  ip.t-=1
	 else
	  pl:_move(cw)
	  for e in all(en) do
	   e:_move(cw)
	  end
	  ip.t=4
		end
 else
  ip.t=0
 end
 
 --end condition
 local t=true
 for r=1,14,1 do --verticals
  for c=1,14,13 do
   t=t and (mp.t[r][c]>0)
  end
 end
 for c=1,14,1 do --horizontals
  for r=1,14,13 do
   t=t and (mp.t[r][c]>0)
  end
 end
 gm.w=t
 
 if(t)then
  gm.e=0
  gm.p=0
  for r=0,15,1 do
   for c=0,15,1 do
    local l=mp.t[r][c]
    if(l==pl.l)gm.p+=1
    if(l==en[0].l)gm.e+=1
   end
  end
  
 end
end

gm={
 w=false,--won
 p=0,
 e=0,
}

function _draw()
	cls()
	--level
	mp:_draw()
	local d=5
	rect(d,d,127-d,127-d,7)
	d=7
	rect(d,d,127-d,127-d,7)
	--players
	pl:_draw()
	for e in all(en) do
	 e:_draw()
	end
	--score
	if(gm.w)print("end "..tostr(gm.p).." vs "..tostr(gm.e).."!")
	--debug
end
-->8
--player

function on_player()

end
-->8
--map

function on_map()

end
-->8
--screens

function on_screen()

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
