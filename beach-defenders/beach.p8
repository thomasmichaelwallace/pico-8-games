pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--beach defender
--by thomas michael wallace
--tomputergames.itch.io

--consts
types={
 se=1,--sea
 sn=2,--sand
 ho=3,--hole
 wl=4,--wall
 ww=12,--wet wall
 fh=5,--filled hole
 kd=9,--kid
 kw=10,--wet kid
 kx=11,--ex kid
}

--globals
function _init()
 sfx(5)
 _init_level()
 _init_player()
end

function _update()
 _update_level()
 _update_player()
 _update_ui()
end

function _draw()
 cls()
 _draw_level()
 _draw_player()
 _draw_ui()
end
-->8
--level

sea={}
beach={}--r/c beach tile types
function _init_level()
 sea={
  sl=0,--sea level (row)
  st=0,--sea timer
  ss=24,--sea speed (frames)
  sd=1,--sea direction
  mv=true,--moving
 }
 for r=0,16 do
  beach[r]={}
  for c=0,16 do
   beach[r][c]=types.sn
  end
 end
end

function _update_level()
 if(sea.mv==false)then
  return
 end
 sea.st+=1
 if(sea.st<sea.ss)then
  return
 end
 --animate sea
 sea.st=1
 sea.sl+=sea.sd
 --switch on dead ui
 if(player.d)player.du=true
 --sea at edge
 if(sea.sl>15)sea.sd=-1
 if(sea.sl==0)sea.sd=1
 if(sea.sl>0)then
  return
 end
 if(player.d)then
  sea.mv=false--stop
  return
 end
 --new level
 player.lv+=1
 sfx(0)
 for a=0,10 do
  --try 10 times
  local c=flr(rnd(16))
  local r=flr(rnd(10))+5
  if(beach[r][c]==types.sn)then
   beach[r][c]=types.kd
   break
  end
 end
end

function fill_hole(r,c)
 if(beach[r]==nil)then
  return
 elseif(beach[r][c]==nil)then
  return
 elseif(beach[r][c]~=types.ho)then
  return
 end
 beach[r][c]=types.fh--fill
 if(r>sea.sl)then
  mset(c,r,types.fh)--redraw
 end
 fill_hole(r,c-1)--⬆️
 fill_hole(r+1,c)--➡️
 fill_hole(r,c+1)--⬇️
 fill_hole(r-1,c)--⬅️
end

function _draw_level()
  --beach/sea
 local w={}--blocked
 for r=0,16 do
  for c=0,16 do
   local s=beach[r][c]
    
   --model tide flow
   if(w[c]==nil)then
				--clear walls on back
				if(sea.sd<0 and sea.sl==r)then
				 if(beach[r+1]~=nil)then
				  if(beach[r+1][c]==types.ww)then
				   beach[r+1][c]=types.sn
				  end
				 end
				end   
   
    if(s==types.wl or s==types.ww)then
     w[c]=true--block
     if(r+1==sea.sl)then
      beach[r][c]=types.ww
     end
    elseif(sea.sl>r)then
     if(s~=types.fh)s=types.se
     local t=beach[r][c]
     if(t==types.kd)then
      --kill a kid
      beach[r][c]=types.kx
      s=types.kw
      player.kn-=1
      
      if(player.kn<0)then
       player.d=true
       sfx(4)
      else
       sfx(1)
      end
     end
     if(t==types.kx)then
      s=types.kw
     end
     if(t==types.ho)then
      fill_hole(r,c)--fill
     end
    end
   end
   
   mset(c,r,s)
  end
 end
 map(0,0,0,0,16,16)
end

-->8
--player

player={}
function _init_player()
	player={
	 x=7,
	 y=8,
	 s=16,
	 d=false,--dead
	 sn=false,--carrying
	 sw=6,--sprite wait
	 sc=7,--sprite carry
	 sd=8,--sprite dead
	 lv=1,--level
	 kn=3,--kids
	 km=3,--max kids
	 du=false,--show dead ui
	}
end

function _update_player()
 if(player.d)then
  return
 end
 
 --kill if in the sea
 local ms=mget(player.x,player.y)
 if(fget(ms,0))then
  sfx(4)
  player.d=true
  return
 end

 --control
 if(btnp(0))then
  player.x-=1
  if(player.x<0)player.x=0
 elseif(btnp(1))then
  player.x+=1
  if(player.x>15)player.x=15
 elseif(btnp(2))then
  player.y-=1
  if(player.y<0)player.y=0
 elseif(btnp(3))then
  player.y+=1
  if(player.y>15)player.y=15
 end
 if(btnp(4)or btnp(5))then
  local r=player.y
  local c=player.x
  local t=beach[r][c]
  if(player.sn)then
   --drop
   if(t==types.sn)t=types.wl
   if(t==types.ho)t=types.sn
  else
   --pickup
   if(t==types.sn)t=types.ho
   if(t==types.wl)t=types.sn
  end
  if(t~=beach[r][c])then
   player.sn=not player.sn
   beach[r][c]=t
   if(player.sn)then
    sfx(2)
   else
    sfx(3)
   end

  end
 end
end

function _draw_player()
 local ps=player.sw
 if(player.sn)ps=player.sc
 if(player.d)ps=player.sd
 spr(ps,player.x*8,player.y*8)
end
-->8
--ui

function _update_ui()
 if(player.du)then
  if(btnp(4) or btnp(5))then
   _init()
  end
 end
end

function _draw_ui()
 local x=56
 rectfill(x,1,126,7,0)
 local s="level:"
 s=s..tostr(player.lv)
 if(player.lv<10)then
  s=s.." "
 end
 s=s.." / "
 for k=0,player.km-1 do
  if(k<player.kn)then
   s=s.."웃"
  else
   s=s.."…"
  end
 end
 print(s,x+2,2,7)
 
 if(player.du)then
  local ex=20
  local ey=44
  rectfill(ex,ey,127-ex,127-ey,0)
  
  ex=22
  ey+=2
  local oy=6
  print("      game over      ",ex,ey+0*oy,14)
  print("       ~  ~  ~       ",ex,ey+1*oy,7)
  print("       -level-       ",ex,ey+2*oy,7)
  //               2
  print("       ~  ~  ~       ",ex,ey+4*oy,7)
  print("press ❎ to try again",ex,ey+5*oy,7)
  local s=tostr(player.lv)
  ex=(128-#s*4)/2
  print(s,ex,ey+oy*3,10)
 end
end
__gfx__
00000000ccccccccaaaaaaaaaa4444aa9999999944cccc44000000000099990000000000aaaaaaaaccccccccaaaaaaaacccccccc000000000000000000000000
00000000ccccccccaaaaaaaaa444444a999999994cccccc400000000099999900cccccc0aaaaaaaaccccccccaccccccac999999c000000000000000000000000
00700700ccccccccaaaaaaaa4444444499999999cccccccc8080080899999999c8eeee8caaaaaaaac8cccc8cc8cccc8c99999999000000000000000000000000
00077000ccccccccaaaaaaaa44444444a999999acccccccc08000080089889800c8dd8c0a8aaaa8acc8ee8cccc8ee8cca999999a000000000000000000000000
00077000ccccccccaaaaaaaa44444444aa9999aacccccccc00d88d00008008000cd88dc0aad88daaccd88dccccd88dccaa9999aa000000000000000000000000
00700700ccccccccaaaaaaaa44444444aa9999aacccccccc0088880000d88d00c8cccc8caa8ee8aac8cccc8cc8cccc8caa9999aa000000000000000000000000
00000000ccccccccaaaaaaaaa444444aaaaaaaaa4cccccc400eeee0000eeee008c8cc8c8aa8aa8aaccccccccaccccccaaaaaaaaa000000000000000000000000
00000000ccccccccaaaaaaaaaa4444aaaaaaaaaa44cccc4408000080080000800cc00cc0aaaaaaaaccccccccaaaaaaaaaaaaaaaa000000000000000000000000
0000000077cc11ccaaaaaaaaa444444aaaaaaaaaacccccca00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ccc77ccca9aaa7aa4544444499999999cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000c11ccc77aaaaaaaa4444444499999999cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ccccccccaaaaaaaa4444544499aaaa99cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000077cc11ccaaaaa9aa444444449aaaaaa9cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ccc77cccaa7aaaaa4445444499999999cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000c11ccc77aaaaaaaa44444454aaaaaaaacccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccccccca9aaaaa7a444444aaaaaaaaaacccccca00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000077cc11ccaaaaaaaaa444444aaaaaaaaaacccccca00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ccc77ccca9aaa7aa4544444499999999cccccccc00000000000000008080080800000000000000000000000000000000000000000000000000000000
00000000c11ccc77aaaaaaaa4444444499999999cccccccc00000000000000000800008000000000000000000000000000000000000000000000000000000000
00000000ccccccccaaaaaaaa4444544499aaaa99cccccccc000000000000000000d88d0000000000000000000000000000000000000000000000000000000000
0000000077cc11ccaaaaa9aa444444449aaaaaa9cccccccc00000000000000000088880000000000000000000000000000000000000000000000000000000000
00000000ccc77cccaa7aaaaa4445444499999999cccccccc000000000000000000eeee0000000000000000000000000000000000000000000000000000000000
00000000c11ccc77aaaaaaaa44444454aaaaaaaacccccccc00000000000000000800008000000000000000000000000000000000000000000000000000000000
00000000cccccccca9aaaaa7a444444aaaaaaaaaacccccca00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000077cc11ccaaaaaaaaa444444aaaaaaaaaacccccca00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ccc77ccca9aaa7aa4544444499999999cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000c11ccc77aaaaaaaa4444444499999999cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ccccccccaaaaaaaa4444544499aaaa99cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000077cc11ccaaaaa9aa444444449aaaaaa9cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ccc77cccaa7aaaaa4445444499999999cccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000c11ccc77aaaaaaaa44444454aaaaaaaacccccccc00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccccccca9aaaaa7a444444aaaaaaaaaacccccca00000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccc00700077707070777070000000777000000000007000000077700000777000007770000c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccc00700070007070700070000700007000000000070000000077700000777000007770000c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccc00700077007070770070000000077000000000070000000777770007777700077777000c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccc00700070007770700070000700007000000000070000000077700000777000007770000c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccc00777077700700777077700000777000000000700000000070700000707000007070000c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000000000000000000000000000000000000000000000000000000000000000000c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc999999cc999999ccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc9999999999999999cccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccca999999aa999999acccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaa9999aaaa9999aacccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaa9999aaaa9999aacccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaacccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaaaaaaaaaaaaaaaacccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccaa4444aaaa4444aacccccccccccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccc999999cccccccccc999999ccccccccccccccccccccccccca444444aa444444ac999999ccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccc99999999cccccccc99999999cccccccccccccccccccccccc444444444444444499999999cccccccccccccccccccccccccccccccc
cccccccccccccccccccccccca999999acccccccca999999acccccccccccccccccccccccc4444444444444444a999999acccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccaa9999aaccccccccaa9999aacccccccccccccccccccccccc4444444444444444aa9999aacccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccaa9999aaccccccccaa9999aacccccccccccccccccccccccc4444444444444444aa9999aacccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccaaaaaaaaccccccccaaaaaaaacccccccccccccccccccccccca444444aa444444aaaaaaaaacccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccaaaaaaaaccccccccaaaaaaaaccccccccccccccccccccccccaa4444aaaa4444aaaaaaaaaacccccccccccccccccccccccccccccccc
ccccccccccccccccccccccccaa4444aaccccccccaa4444aaccccccccccccccccccccccccaaaaaaaaaaaaaaaaaa4444aacccccccccccccccccccccccccccccccc
ccccccccccccccccc999999ca444444acccccccca444444accccccccccccccccccccccccaaaaaaaaaaaaaaaaa444444accccccccc999999ccccccccccccccccc
cccccccccccccccc9999999944444444cccccccc44444444ccccccccccccccccccccccccaaaaaaaaaaaaaaaa44444444cccccccc99999999cccccccccccccccc
cccccccccccccccca999999a44444444cccccccc44444444ccccccccccccccccccccccccaaaaaaaaaaaaaaaa44444444cccccccca999999acccccccccccccccc
ccccccccccccccccaa9999aa44444444cccccccc44444444ccccccccccccccccccccccccaaaaaaaaaaaaaaaa44444444ccccccccaa9999aacccccccccccccccc
ccccccccccccccccaa9999aa44444444cccccccc44444444ccccccccccccccccccccccccaaaaaaaaaaaaaaaa44444444ccccccccaa9999aacccccccccccccccc
ccccccccccccccccaaaaaaaaa444444acccccccca444444accccccccccccccccccccccccaaaaaaaaaaaaaaaaa444444accccccccaaaaaaaacccccccccccccccc
ccccccccccccccccaaaaaaaaaa4444aaccccccccaa4444aaccccccccccccccccccccccccaaaaaaaaaaaaaaaaaa4444aaccccccccaaaaaaaacccccccccccccccc
ccccccccccccccccaaaaaaaaaaaaaaaacccccccc9999999944cccc4444cccc44ccccccccaaaaaaaa99999999aaaaaaaaccccccccaa4444aacccccccccccccccc
ccccccccccccccccaaaaaaaaaaaaaaaacccccccc999999994cccccc44cccccc4ccccccccaaaaaaaa99999999aaaaaaaacccccccca444444acccccccccccccccc
ccccccccccccccccaaaaaaaaaaaaaaaacccccccc99999999ccccccccccccccccccccccccaaaaaaaa89899898aaaaaaaacccccccc44444444cccccccccccccccc
ccccccccccccccccaaaaaaaaaaaaaaaacccccccca999999accccccccccccccccccccccccaaaaaaaaa899998aaaaaaaaacccccccc44444444cccccccccccccccc
ccccccccccccccccaaaaaaaaaaaaaaaaccccccccaa9999aaccccccccccccccccccccccccaaaaaaaaaad88daaaaaaaaaacccccccc44444444cccccccccccccccc
ccccccccccccccccaaaaaaaaaaaaaaaaccccccccaa9999aaccccccccccccccccccccccccaaaaaaaaaa8888aaaaaaaaaacccccccc44444444cccccccccccccccc
ccccccccccccccccaaaaaaaaaaaaaaaaccccccccaaaaaaaa4cccccc44cccccc4ccccccccaaaaaaaaaaeeeeaaaaaaaaaacccccccca444444acccccccccccccccc
ccccccccccccccccaaaaaaaaaaaaaaaaccccccccaaaaaaaa44cccc4444cccc44ccccccccaaaaaaaaa8aaaa8aaaaaaaaaccccccccaa4444aacccccccccccccccc
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4444aaaa4444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa444444aa444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4444444444444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa44444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4444444444444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa44444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4444444444444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa44444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4444444444444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa44444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa444444aa444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4444aaaa4444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaa99999999aaaaaaaaaaaaaaaaaaaaaaaa99999999aaaaaaaa44cccc44aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaa99999999aaaaaaaaaaaaaaaaaaaaaaaa99999999aaaaaaaa4cccccc4aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaa99999999aaaaaaaaaaaaaaaaaaaaaaaa99999999aaaaaaaaccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaa999999aaaaaaaaaaaaaaaaaa8aaaa8aa999999aaaaaaaaaccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa8aaaa8aaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaa9999aaaaaaaaaaaaaaaaaaaad88daaaa9999aaaaaaaaaaccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaad88daaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaa9999aaaaaaaaaaaaaaaaaaaa8ee8aaaa9999aaaaaaaaaaccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa8ee8aaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa8aa8aaaaaaaaaaaaaaaaaa4cccccc4aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa8aa8aaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa44cccc44aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaa4444aaaaaaaaaaaaaaaaaaaa4444aaaaaaaaaaaaaaaaaa44cccc4444cccc4444cccc44aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaa444444aaaaaaaaaaaaaaaaaa444444aaaaaaaaaaaaaaaaa4cccccc44cccccc44cccccc4aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaa44444444aaaaaaaaaaaaaaaa44444444aaaaaaaaaaaaaaaaccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaa44444444aaaaaaaaaaaaaaaa44444444aaaaaaaaaaaaaaaaccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaa44444444aaaaaaaaaaaaaaaa44444444aaaaaaaaaaaaaaaaccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaa44444444aaaaaaaaaaaaaaaa44444444aaaaaaaaaaaaaaaaccccccccccccccccccccccccaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaa444444aaaaaaaaaaaaaaaaaa444444aaaaaaaaaaaaaaaaa4cccccc44cccccc44cccccc4aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaa4444aaaaaaaaaaaaaaaaaaaa4444aaaaaaaaaaaaaaaaaa44cccc4444cccc4444cccc44aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa99999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa99999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa99999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa9999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa9999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaa99999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4444aaaa4444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaa99999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa444444aa444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaa99999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4444444444444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaa999999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4444444444444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaa9999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4444444444444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaa9999aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4444444444444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa444444aa444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa4444aaaa4444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaa4444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaa444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaa44444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaa44444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaa44444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaa44444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaa444444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaa4444aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa

__gff__
0001000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000c0000170400000013040000001c040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00000e050000000d050000000c050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c21718000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c05700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0110000011050100500f0500e0500c0500000000000000000d0500c0500d050000000c05000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c0500c050000000f0500e05000000000000c0500c050000000c050000000f0500e05000000000000c0500c050000000f0500e05000000000000b050000000c050000000000000000000000000000000
