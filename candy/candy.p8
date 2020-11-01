pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- sugarush
-- by thomas michael wallace

state=0--0:intro 1:game 2:end

lvl={
 w=0,--wait until next
 w_max=30,--max wait until next
 s=0,--score
 l=0,--level
 v=0,--fall-rate
}

ani={
 t=0,--count
 k=false,--tick
 r=6,--frame rate
 h=false,
}

you={
	x=0,--x position
	y=88,--/y
	v=0,--velocity
	s=1,--sprite
}


function set_level()
 local s=lvl.s
 --let level by score
 lvl.v=min(1+s/10,5)
 you.v=min(1+s/10,5)
 lvl.w_max=max(0,30-s)
end

function _init_game()
 --reset
 _init_stars()
 actors={}
 you.x=60
 lvl.s=0
 set_level()
 --start
 state=1
end

function _update_screen()
 if(btnp(0)or btnp(1))_init_game()
end

function _draw_screen()
 cls()
 if(state==0)then
  print("sugarush")
 else
  print("gameover")
  print("you scored "..lvl.s)
 end
 print("⬅️/➡️ to start")
end

function _update_game()
 --movement
 if(btn(0))you.x-=you.v
 if(btn(1))you.x+=you.v
 you.x=mid(0,you.x,120)
 --animation
 ani.t+=1
 ani.k=(ani.t>ani.r)
 if(ani.k)then
  you.s+=1
  if(you.s>2)you.s=1
  ani.t=0
 end 
 --actors
 for a in all(actors) do
  a:_update()
		if(a.y>you.y and a.y<(you.y+8))then
		 if(a.x>(you.x-8) and a.x<(you.x+8))then
		 	del(actors,a)
		 	if(a.f)then
		 	 --state=2
		 	else
		 	 lvl.s+=1
		 	 set_level()
		 	end
		 end
		end
 end
 --spawn
 lvl.w-=1
 if(lvl.w<0)then
  add_actor()
  lvl.w=5+flr(rnd(lvl.w_max))
 end
 --stars
 for s in all(stars) do
  s:_update()
 end
end

function _draw_game()
 cls()
 for s in all(stars) do
  s:_draw()
 end
 --player
 spr(you.s,you.x,you.y)
 --actors
 for a in all(actors) do
  a:_draw()
 end
 --score
 print(lvl.s)
end

function _update()
 if(state==1)then
  _update_game()
 else
  _update_screen()
 end
end

function _draw()
 if(state==1)then
  _draw_game()
 else
  _draw_screen()
 end
end
-->8
--actors

actors={}

function add_actor()
 local t=flr(rnd(5))+1
 local f=(rnd(1)<0.5)

 local a={
 	x=flr(rnd(121)), --pos x/
 	y=-8,--/y
 	t=t,--type (1-5) as sprite no
 	f=f,--is fruit
 	s=t+(f and 2 or 18),--sprite
 	r=0,
 	_draw=function(self)
 	 local fx=(self.r>0 and self.r<3)
   local fy=(self.r>1)
 	 spr(self.s,self.x,self.y,1,1,fx,fy)
 	end,
 	_update=function(self)
 		self.y+=lvl.v
 		
 		if(ani.k)self.r+=1
 		if(self.r>3)self.r=0
 		if(self.y>128)del(actors,self)
 	end
 }
 add(actors,a)
end
-->8
--stars

stars={}
tail={5,1,2,13,8,14,9,10,11,12,6,7}

function add_star()
 local s={
  x=flr(rnd(128)),
  y=flr(rnd(128)),
  v=0.5+rnd(0.5),
  d=0,
  _update=function(self)
   self.d=lvl.v*self.v
   self.y+=self.d
   if(self.y>148)then
    self.x=flr(rnd(128))
    self.y=0
   end
  end,
  _draw=function(self)
   for o=0,self.d*4,1 do
    pset(self.x,self.y+o,tail[o+1])
   end
  end,
 }
 add(stars,s)
end

function _init_stars()
 stars={}
 for i=0,20,1 do
  add_star()
 end
end

__gfx__
000000000787878000ffff00000000000333bb30000000000b000000333000000000000000000000000000000000000000000000000000000000000000000000
0000000008888880087878700400000033b3bb3000fff444bb888800b39990000000000000000000000000000000000000000000000000000000000000000000
00700700f888888ff888888f0aa000003bb33330f44ff4ff08ee8880b99990000000000000000000000000000000000000000000000000000000000000000000
00077000f878787ff787878faaa00000b3b33000f4ffffff8ee88888099499000000000000000000000000000000000000000000000000000000000000000000
00077000ffffffffffffffffaaaa0000b3333b00fffffff48e888888094999000000000000000000000000000000000000000000000000000000000000000000
00700700f75ff57ff57ff75f0aaaaa00bb33bbb0f4fff4f488888888000949900000000000000000000000000000000000000000000000000000000000000000
00000000f77444444444477f04aaaa403bb00bbb044f4f0008888880000009990000000000000000000000000000000000000000000000000000000000000000
000000000444444004444440000aa000033000b30000000000888800000000990000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000099900000ccc00000ddd00000888000003330000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000009a999000c7ccc000d6ddd0008e8880003b333000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000099999000ccccc000ddddd0008888800033333000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000099999000ccccc000ddddd0008888800033333000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000099900000ccc00000ddd00000888000003330000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000044440000099900000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000455400009a9990000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000045440000999990000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000077e77e77e77e77e0000000000044440000999990000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000aaaaaaaaaaaaaaa0000000000044444444099900000000000000000000000000000000000000000000
009990000088800000ddd00000ccc00000333000000000aaaaaaaaaaaaaaa0000000000045544554000000000000000000000000000000000000000000000000
09a99900089888000deddd000c6ccc0003b33300000000aaaaaaaaaaaaaaa0000000000045444544000000000000000000000000000000000000000000000000
09999900088888000ddddd000ccccc00033333000000007777777777777770000000000044444444000000000000000000000000000000000000000000000000
09999900088888000ddddd000ccccc0003333300000000eeeeeeeeeeeeeee0000000000044444444000000000000000000000000000000000000000000000000
009990000088800000ddd00000ccc00000333000000000eeeeeeeeeeeeeee0000000000045544554000000000000000000000000000000000000000000000000
0007000000070000000700000007000000070000000000eeeeeeeeeeeeeee0000000000045444544000000000000000000000000000000000000000000000000
0007000000070000000700000007000000070000000000eeeeeeeeeeeeeee0000000000044444444000000000000000000000000000000000000000000000000
00070000000700000007000000070000000700000000007777777777777770000000000066666666000000000000000000000000000000000000000000000000
0007000000070000000700000007000000070000000000fffffffffffffff00055555555e888888e000000000000000000000000000000000000000000000000
0007000000070000000700000007000000070000000000fffffffffffffff00007777770e8eeee8e000000000000000000000000000000000000000000000000
0007000000070000000700000007000000070000000000fffffffffffffff00055555555e888888e000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000e8ee888e000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000e888888e000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000e888888e000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeee000000000000000000000000000000000000000000000000
__gff__
0000000101010101000000000000000000000002020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
