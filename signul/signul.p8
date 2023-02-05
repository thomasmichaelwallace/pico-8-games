pico-8 cartridge // http://www.pico-8.com
version 39
__lua__
-- signul
-- by thomas michael wallace
-- tomputergames.itch.io

function _init()
 --init/reset game
 _init_game()
 _init_st()
 _init_ns()
 _init_bs()
 _init_es()
 _set_tune(1)
end

function _update()
 if(gm.m==2)then
	 _update_st()
	 _update_ns()
	 _update_bs()
	 _update_es()
	else
	 _update_screen()
	end
end

function _draw()
 cls()
 _draw_st()
 _draw_ns()
 _draw_bs()
 _draw_es()
 rectfill(0,0,128,8,0)
 line(0,8,128,8,5)
 _draw_game()
 _draw_screen()
end
-->8
-- shooter

st={}

function _init_a_st(x,y,c)
 local s={
  x=x,y=y,c=c,
  h=false,--hit
  a={o=0,n=1,f=1,t=2},
  _shoot=function(t)
   _init_a_bs(t.x+4,t.y+8,t.c)
  end,
  _hit=function(t)
   sfx(5)
   t.h=true
   t.a.n=1
   t.a.f=1
   gm.l-=1
   if(gm.l<1)then
    gm.m=3
   end
  end,
  _update=function(t)
   if(t.h)then
    t.a.f+=1
    if(t.a.f>t.a.t)then
     if(t.a.n==1)t.a.o=-1
     if(t.a.n==2)t.a.o=0
     if(t.a.n==3)t.a.o=1
     if(t.a.n==4)then
      t.a.o=0
      t.a.n=0
      t.h=false
     end
     t.a.n+=1
     t.a.f=1
    end
   end
  end,
  _draw=function(t)
   local n=t.c*2
   spr(n,t.x-t.a.o,t.y,2,2)
  end,
 }
 add(st,s)
end

function _init_st()
 st={}
 local y=88
 local s=8 -- spacing
 local x=(128-(16*4+s*3))/2
 for c=1,4,1 do
  _init_a_st(x,y,c)
  x+=(16+s)
 end
end

function _update_st()
 for s in all(st) do
  s:_update()
 end
end

function _draw_st()
 --background
 local y=88+16-2
 line(0,y,128,y,7)
 y+=2
 line(0,y,128,y,6)
 y+=2
 line(0,y,128,y,5)
 --shooters
 for s in all(st) do
  s:_draw()
 end
end
-->8
-- notations

ns={}
tk={} --ticker

function _init_a_ns(x,c)
 local n={
  x=x,c=c,
  y=tk.y,
  _update=function(t)
  
  end,
  _draw=function(t)
   local n=32+(t.c*2)
   spr(n,t.x,t.y)
  end,
 }
 add(ns,n)
end

function _init_ns()
 ns={}
 --init_tk
 tk={
  x=128,y=110,
  s=1,--speed
  l=16,r=(128-16-8),--left/right
  n=1,--tune
  _update=function(t)
  	if(btnp(2))then
  	 t.n+=1
  	 if(t.n>#ts)t.n=1
  	 _set_tune(t.n)
  	elseif(btnp(3))then
  	 t.n-=1
  	 if(t.n<1)t.n=#ts
  	 _set_tune(t.n)
  	end
  
   local l=t.x --left point
   t.x+=t.s
   if(t.x>t.r)then
    t.x=t.l
    return --cannot hit
   end
   --check hit
   for n in all(ns) do
    if(n.x>l and n.x<=t.x)then
     st[n.c]:_shoot()
    end
   end
  end,
  _draw=function(t)
   spr(50,t.x,t.y)
  end
 }
end

function _update_ns()
 tk:_update()
 for n in all(ns) do
  n:_update()
 end
end

function _draw_ns()
 local y=tk.y+4
 line(tk.l+2,y,tk.r+6,y,5)
 for n in all(ns) do
  n:_draw()
 end
 tk:_draw()
end
-->8
-- bullets

bs={}

function _init_a_bs(x,y,c)
 sfx(c-1)
 local b={
  x=x,y=y,c=c,
  s=3,
  _draw=function(t)
   local n=32+t.c*2
   spr(n,t.x,t.y)
  end,
  _update=function(t)
   t.y-=t.s
   if(t.y<0)del(bs,t)
  end
 }
 add(bs,b)
end

function _init_bs()
 bs={}
end

function _update_bs()
 for b in all(bs) do
  b:_update()
 end
end

function _draw_bs()
 for b in all(bs) do
  b:_draw()
 end
end
-->8
-- enemies

es={}
sp={t=0,m=6,s=30}

function _init_a_es(c)
 local e={
  x=st[c].x+4,
  y=0,
  s=1,
  d=false,--dead if true
  a={s=42,f=1,t=8},
  l=88+2,--lower position
  _update=function(t)
   local s=1+(gm.s)*0.01
   if(t.d)s=0.25
   t.y+=s
	  for b in all(bs) do
    if(b.x==t.x and t.d==false)then
     if(b.y<(t.y+4))then
      del(bs,b)
      t.s=0.25
      t.a.s=44
      t.a.f=1
      t.d=true
      --score!
      gm.s+=1
      if(gm.s%5==0)then
       sp.s-=1
       tk.s+=0
       sp.s=max(10,sp.s)
       tk.s=min(2,tk.s)
      end
      sfx(4)
     end
    end
   end
   if(t.y>t.l and t.d==false)then
   	t.s=0.25
   	t.a.s=44
    t.a.f=1
    t.d=true
    st[c]:_hit()
   end
  end,
  _draw=function(t)
   t.a.f+=1
   if(t.a.f>t.a.t)then
    if(t.a.s==42)then
     t.a.s+=1--move a
    elseif(t.a.s==43)then
     t.a.s-=1--move b
    elseif(t.a.s==44)then
     t.a.s+=1--die a
    elseif(t.a.s==45)then
     del(es,t)
    end
    t.a.f=1
   end
   spr(t.a.s,t.x,t.y)
  end,
 }
 add(es,e)
end

function _init_es()
 es={}
 sp={
  t=0,
  m=6,
  s=30,
 }
end

function _update_es()
 sp.t+=1
 if(sp.t>sp.s)then
  local c=flr(rnd(sp.m))+1
  if(c<=4)_init_a_es(c)
  sp.t=0
 end
 for e in all(es) do
  e:_update()
 end
end

function _draw_es()
 for e in all(es) do
  e:_draw()
 end
end
-->8
-- tunes

ts={
 {1,0,0,3, 1,0,0,0},
 {2,0,3,0, 2,0,3,4},
 {4,3,0,0, 1,0,4,3},
 {1,2,0,0, 2,3,0,0},
 {3,0,4,0, 3,0,4,1}
}

function _set_tune(n)
 local t=ts[n]
 
 ns={}
 if(t==nil)return
 
 local c=#t
 local s=(tk.r-tk.l)/c
 local x=tk.l+1
 for c in all(t) do
  if(c>0)_init_a_ns(x,c)
  x+=s
 end
end
-->8
--game

gm={
 --s=0,--score
 --l=5,--lives
 m=1,--mode (1title;game;end)
}

function _init_game()
 gm.s=0
 gm.l=5
end

function _draw_game()
 print(tostr(gm.s),2,2,7)
 local l=""
 for n=1,gm.l,1 do
  l=l.."♥"
 end
 print(l,126-#l*8,2,14)
 local s="tune "..tostr(tk.n).."/"..tostr(#ts)
 local x=(128-#s*4)/2
 print(s,x,120,6)
end
-->8
-- screens

function strlen(s)
 return #tostr(s)*4
end

function _update_screen()
 if(btnp(4)or btnp(5))then
  gm.m=2
  _init()
 end
end

function _draw_screen()
 local w=88
 local h=40
 if(gm.m==1)then
  --title
  local x=(128-w)/2
  local y=(128-h)/2-12
  rectfill(x,y,x+w,y+h,0)
  rect(x+1,y+1,x+w-1,y+h-1,7)
  y+=4
  x=(128-16)/2
  spr(10,x,y,2,2)
  y+=18
  s="s i g n u l"
  x=(128-strlen(s))/2-1
  print("s i g",x,y,14)
  print(" n u l",x+strlen(s)/2,y,7)
  y+=8
  s="press ❎/🅾️ to start"
  x=(128-strlen(s))/2-3
  print(s,x,y,6)
 elseif(gm.m==3)then
  --gameover
  local x=(128-w)/2
  local y=(128-h)/2-12
  rectfill(x,y,x+w,y+h,0)
  rect(x+1,y+1,x+w-1,y+h-1,7)
  
  y+=6
  local s="gameover"
  x=(128-strlen(s))/2-1
  print(s,x,y,14)
  
  y+=8
  local s="you scored"
  x=(128-strlen(s))/2-1
  print(s,x,y,7)
  
  y+=8
  local s="~ "..tostr(gm.s).." ~"
  x=(128-strlen(s))/2-1
  print("~ ",x,y,7)
  print(gm.s,x+8,y,14)
  print(" ~",128-x-10,y,7)
  
  y+=8
  s="press ❎/🅾️ to reset"
  x=(128-strlen(s))/2-3
  print(s,x,y,6)
 end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000000000000000000000000000000000000000000000000000000000000000000000000000eee000000eee0000eee000000eee0000eee000000eee00
000770000000000000000cccccc00000000008888880000000000bbbbbb0000000000aaaaaa000000eeeeeddddeeeee00eeeeeddddeeeee00eeeeeddddeeeee0
00077000000000000000cc0000cc000000008800008800000000bb0000bb00000000aa0000aa00000eeddd7777dddee00eeddd7777dddee00eeddd7777dddee0
0070070000000000000c00000000c0000008000000008000000b00000000b000000a00000000a00000eeedeeeedeee0000eeedeeeedeee0000eeedeeeedeee00
000000000000000000c0000000000c00008000000000080000b0000000000b0000a0000000000a0000000d7777d0000000000d7777d0000000000d7777d00000
000000000000000000c0000000000c00008000000000080000b0000000000b0000a0000000000a000000dddddddd00000000dddddddd00000000dddddddd0000
00000000000000000cc0000000000cc008800000000008800bb0000000000bb00aa0000000000aa0000dddeeeeddd000000dddeeeeddd000000dddeeeeddd000
00000000000000000c1c00000000c1c008280000000082800b3b00000000b3b00a9a00000000a9a000eddeeeeeedde0000eddeeeeeedde0000eddeeeeeedde00
00000000000000000c11c000000c11c008228000000822800b33b000000b33b00a99a000000a99a00e77dddddddd77e00e77dddddddd77e00e77dddddddd77e0
0000000000000000c1111cccccc1111c8222288888822228b3333bbbbbb3333ba9999aaaaaa9999a00ed777ee777de0000ed777ee777de0000ed777ee777de00
0000000000000000c11111111111111c8222222222222228b33333333333333ba99999999999999a00eeddddddddee0000eeddddddddee0000eeddddddddee00
0000000000000000ccc1111111111ccc8882222222222888bbb3333333333bbbaaa9999999999aaa000000eeee000000000700eeee007000000000eeee000000
0000000000000000c11cccccccccc11c8228888888888228b33bbbbbbbbbb33ba99aaaaaaaaaa99a0000000ee0000000000d000ee000d0000000000ee0000000
0000000000000000c11111111111111c8222222222222228b33333333333333ba99999999999999a000000000000000000000007700000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000ee0000ee0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000edddde0ee0000ee00000000000000000000000000000000
0000000000000000000cc000000000000008800000000000000bb00000000000000aa000000000000ed77de00edddde00edddde0000000000000000000000000
00000000000000000011cc000000000000228800000000000033bb00000000000099aa00000000000dddddd00dd77dd00dd77dd0000770000000000000000000
000000000000000000111c0000000000002228000000000000333b000000000000999a00000000000d7ee7d00d7ee7d00dd77dd0000770000000000000000000
00000000000000000001100000000000000220000000000000033000000000000009900000000000edd77ddeedd77dde0dd77dd0000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000edddde00edddde00edddde0000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000ee000000ee00000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000ee0000ee0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000edddde00000000000000000000000000000000000000000
000000000000000000077000000000000000000000000000000000000000000000000000000000000ed77de00000000000000000000000000000000000000000
000000000000000000750700000000000000000000000000000000000000000000000000000000000dddddd00000000000000000000000000000000000000000
000000000000000000755700000000000000000000000000000000000000000000000000000000000d7ee7d00000000000000000000000000000000000000000
00000000000000000007700000000000000000000000000000000000000000000000000000000000edd77dde0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000edddde00000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000ee0000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007770000000000000000000000000000000000000000000000000000000000000000000000000000000000ee0ee000ee0ee000ee0ee000ee0ee000ee0ee0000
007070000000000000000000000000000000000000000000000000000000000000000000000000000000000eeeee000eeeee000eeeee000eeeee000eeeee0000
007070000000000000000000000000000000000000000000000000000000000000000000000000000000000eeeee000eeeee000eeeee000eeeee000eeeee0000
0070700000000000000000000000000000000000000000000000000000000000000000000000000000000000eee00000eee00000eee00000eee00000eee00000
00777000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000e0000000e0000000e0000000e000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000077777777777777777777777777777777777777777777777777777777777777777777777777777777777777700000000000000000000
00000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000
00000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000
00000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000
00000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000
0000000000000000000007000000000000000000000000000000000000eee000000eee0000000000000000000000000000000000000700000000000000000000
000000000000000000000700000000000000000000000000000000000eeeeeddddeeeee000000000000000000000000000000000000700000000000000000000
000000000000000000000700000000000000000000000000000000000eeddd7777dddee000000000000000000000000000000000000700000000000000000000
0000000000000000000007000000000000000000000000000000000000eeedeeeedeee0000000000000000000000000000000000000700000000000000000000
0000000000000000000007000000000000000000000000000000000000000d7777d0000000000000000000000000000000000000000700000000000000000000
000000000000000000000700000000000000000000000000000000000000dddddddd000000000000000000000000000000000000000700000000000000000000
00000000000000000000070000000000000000000000000000000000000dddeeeeddd00000000000000000000000000000000000000700000000000000000000
0000000000000000000007000000000000000000000000000000000000eddeeeeeedde0000000000000000000000000000000000000700000000000000000000
000000000000000000000700000000000000000000000000000000000e77dddddddd77e000000000000000000000000000000000000700000000000000000000
0000000000000000000007000000000000000000000000000000000000ed777ee777de0000000000000000000000000000000000000700000000000000000000
0000000000000000000007000000000000000000000000000000000000eeddddddddee0000000000000000000000000000000000000700000000000000000000
00000000000000000000070000000000000000000000000000000000000000eeee00000000000000000000000000000000000000000700000000000000000000
000000000000000000000700000000000000000000000000000000000000000ee000000000000000000000000000000000000000000700000000000000000000
00000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000
00000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000
00000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000
000000000000000000000700000000000000000000ee00000eee000000ee00000007700000070700000700000000000000000000000700000000000000000000
00000000000000000000070000000000000000000e00000000e000000e0000000007070000070700000700000000000000000000000700000000000000000000
00000000000000000000070000000000000000000eee000000e000000e0000000007070000070700000700000000000000000000000700000000000000000000
0000000000000000000007000000000000000000000e000000e000000e0e00000007070000070700000700000000000000000000000700000000000000000000
00000000000000000000070000000000000000000ee000000eee00000eee00000007070000007700000777000000000000000000000700000000000000000000
00000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000
00000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000
00000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000
00000000000000000000070006660666066600660066000000666660000600666660000006660066000000660666066606660666000700000000000000000000
00000000000000000000070006060606060006000600000006606066006006600066000000600606000006000060060606060060000700000000000000000000
00000000000000000000070006660660066006660666000006660666006006606066000000600606000006660060066606600060000700000000000000000000
00000000000000000000070006000606060000060006000006606066006006600066000000600606000000060060060606060060000700000000000000000000
00000000000000000000070006000606066606600660000000666660060000666660000000600660000006600060060606060060000700000000000000000000
00000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000
00000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000
00000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000
00000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000700000000000000000000
00000000000000000000077777777777777777777777777777777777777777777777777777777777777777777777777777777777777700000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000cccccc000000000000000000888888000000000000000000bbbbbb000000000000000000aaaaaa0000000000000000000000000
000000000000000000000000cc0000cc0000000000000000880000880000000000000000bb0000bb0000000000000000aa0000aa000000000000000000000000
00000000000000000000000c00000000c00000000000000800000000800000000000000b00000000b00000000000000a00000000a00000000000000000000000
0000000000000000000000c0000000000c000000000000800000000008000000000000b0000000000b000000000000a0000000000a0000000000000000000000
0000000000000000000000c0000000000c000000000000800000000008000000000000b0000000000b000000000000a0000000000a0000000000000000000000
000000000000000000000cc0000000000cc0000000000880000000000880000000000bb0000000000bb0000000000aa0000000000aa000000000000000000000
000000000000000000000c1c00000000c1c0000000000828000000008280000000000b3b00000000b3b0000000000a9a00000000a9a000000000000000000000
000000000000000000000c11c000000c11c0000000000822800000082280000000000b33b000000b33b0000000000a99a000000a99a000000000000000000000
00000000000000000000c1111cccccc1111c00000000822228888882222800000000b3333bbbbbb3333b00000000a9999aaaaaa9999a00000000000000000000
00000000000000000000c11111111111111c00000000822222222222222800000000b33333333333333b00000000a99999999999999a00000000000000000000
00000000000000000000ccc1111111111ccc00000000888222222222288800000000bbb3333333333bbb00000000aaa9999999999aaa00000000000000000000
77777777777777777777c11cccccccccc11c77777777822888888888822877777777b33bbbbbbbbbb33b77777777a99aaaaaaaaaa99a77777777777777777777
00000000000000000000c11111111111111c00000000822222222222222800000000b33333333333333b00000000a99999999999999a00000000000000000000
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000cc0000000000000000000000000000000bb000000000cc00000000000000000000000000000000000000000000000000000000000000
000000000000000000011cc0000000000000000000000000000033bb000000011cc0000000000000000000000000000000000000000000000000000000000000
0000000000000000005111c55555555555555555555555555555333b5555555111c5555555555555555555555555555555555555555555500000000000000000
00000000000000000000110000000000000000000000000000000330000000001100000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000066606060660066600000660000606060000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000006006060606060000000060006006060000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000006006060606066000000060006006660000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000006006060606060000000060006000060000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000006000660606066600000666060000060000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
011e00001855000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e00001c55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e00001d55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011e00001f55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000000c05100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000000510d051000510205100051000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
