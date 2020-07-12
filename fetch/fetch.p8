pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--fetch!
--@thomasmichaelwallace

game={
 score=0
}

--reset the game to its initial
--state. use this instead of
--_init()
function reset()
	ticks=0
	p1=m_player(30,70)
	p1:set_anim("walk")
	
	--b1=m_ball(0,rnd(game.max_h),rnd(game.max_v),rnd(game.max_v),2)
	b1=m_ball(0,40,2,-1,2)
	m1=m_man(10,56)
	m_text(20,56,"play time!")
	cam=m_cam(p1)
end

--p8 functions
--------------------------------

function _init()
	reset()
end

function _update60()
	ticks+=1
	update_texts()
	m1:update()
	p1:update()
	b1:update()
	cam:update()
	
	--demo camera shake
	if btnp(4) then
	 cam:shake(15,2)
	 sfx(0)
	end
end

function _draw()

	cls(0)
	
	camera(cam:cam_pos())
	
	map(0,0,0,0,128,128)
	
	m1:draw()
	p1:draw()
	b1:draw()
	draw_texts()
	
	--hud
	--camera(0,0)

	--printc("adv. micro platformer",64,4,7,0,0)

end
-->8
-- ball

function m_ball(x,y,dx,dy,d)
 local b=
 {
  x=x,
  y=y,
  dx=dx,
  dy=dy,
  d=2,
  w=d,
  h=d,
  max_dx=5,
  max_dy=5,
  acc=0.1,
  dcc=0.9,
  air_dcc=1,
  ground_dcc=0.95,
  grav=0.15,
  curframe=1,
  animtick=0,
  caught=false,
  held=true,
  
  throw=function(self)
   self.held=false
   self.caught=false
   self.x=22
   self.y=55
   self.dx=rnd(3)+1
   self.dy=-1*rnd(2)
  end,
  
  update=function(self)
   if self.held then
    self:update_held()
   elseif not self.caught then
    self:update_motion()
    if intersects_point_box(self.x,self.y,p1.x,p1.y,8,8) then
     self.caught=true
     local score=flr(max(abs(self.dx*10),abs(self.dy*10)))+1
     m_text(self.x,self.y,score.."!")
     game.score+=score
    end
   else
    self:update_caught()
   end
  end,
  
  update_held=function(self)
   self.x=m1.x+9
   self.y=m1.y+10
  end,
  
  update_caught=function(self)
   if p1.flipx then
    self.x=(p1.x-3)
   else
    self.x=(p1.x+2)
   end
   self.y=p1.y
  end,
  
  update_motion=function(self)
   if self.x<0 then
    self.held=true
    self.caught=false
    return
  	end
  	self.dx*=self.air_dcc
   
   self.dx=mid(-self.max_dx,self.dx,self.max_dx)
   self.x+=self.dx
   
   local bounce_dx=self.dx
   if collide_side(self) then
    self.dx=-(bounce_dx*self.dcc)
   end
   
   self.dy+=self.grav
   self.dy=mid(-self.max_dy,self.dy,self.max_dy)
   self.y+=self.dy
      
   local bounce_dy=self.dy
   if collide_floor(self) then
    self.dy=-(bounce_dy*self.dcc)
    self.dx*=self.ground_dcc
   end

   local fr=max(abs(self.dx),abs(self.dy))
   if (fr>self.grav) then
  	 self.animtick-=1*fr
   	if self.animtick<=0 then
    	self.curframe-=(1*sgn(self.dx))
    	self.animtick=5
    	if self.curframe>4 then
     	self.curframe=1
    	elseif self.curframe<1 then
    	 self.curframe=4
   	 end
   	end
   end
  end,

  draw=function(self)
   circfill(self.x,self.y,self.d/2,9)
   local as=sgn(self.curframe-3)
   local ax=(self.curframe%2)*as
   local ay=((self.curframe%2)-1)*as
   
   pset(self.x+ax,self.y+ay,8)
  end,
 }
 return b 
end
-->8
-- man

function m_man(x,y)
 local m={
  x=x,
  y=y,
  waiting=false,
  waitticks=30,
  waittick=0,
  tick=0,
  saytick=0,
  
  update=function(self)
   if (self.waiting and p1.sat and b1.held) then
    self.waittick+=1
    if (self.waittick>self.waitticks) then
     b1:throw()
     m_text(20,56,"fetch!")
     sfx(snd.fetch,1)
     self.waiting=false
     self.tick=5
    end
   end
   if (self.waiting and not p1.sat and b1.held) then
    self.waittick=-rnd(0,10)
   end
   if not self.waiting then
    self.tick-=1
    if self.tick<0 then
     self.waittick=0
     self.waiting=true
    end
   end
   
   if (
    self.waiting and
    b1.caught and
    not b1.held and
    intersects_point_box(b1.x,b1.y,x,y,12,16)
   ) then
    b1.held=true
   end
   
   self.saytick+=1
   if self.saytick>60 then
	   self.saytick=-100
	   if (
	    self.waiting and
	    b1.held and
	    self.waittick==0
	   ) then
	    m_text(20,56,"sit!")
	    sfx(snd.sit,1)
	   elseif (
	    self.waiting and
	    b1.caught and
	    not b1.held
	   ) then
	    m_text(20,56,"♪!")
	    sfx(snd.come,1)
	   end
	  end
  end,
  
  draw=function(self)
   local sprite=17
   if (not self.waiting) sprite=19
   spr(sprite,self.x,self.y,2,2)
  end
 }
 
 return m
end
-->8
-- camera

--make the camera.
function m_cam(target)
	local c=
	{
		tar=target,--target to follow.
		pos=m_vec(target.x,target.y),
		
		--how far from center of screen target must
		--be before camera starts following.
		--allows for movement in center without camera
		--constantly moving.
		pull_threshold=16,

		--min and max positions of camera.
		--the edges of the level.
		pos_min=m_vec(64,64),
		pos_max=m_vec(192,64),
		
		shake_remaining=0,
		shake_force=0,

		update=function(self)

			self.shake_remaining=max(0,self.shake_remaining-1)
			
			--follow target outside of
			--pull range.
			if self:pull_max_x()<self.tar.x then
				self.pos.x+=min(self.tar.x-self:pull_max_x(),4)
			end
			if self:pull_min_x()>self.tar.x then
				self.pos.x+=min((self.tar.x-self:pull_min_x()),4)
			end
			if self:pull_max_y()<self.tar.y then
				self.pos.y+=min(self.tar.y-self:pull_max_y(),4)
			end
			if self:pull_min_y()>self.tar.y then
				self.pos.y+=min((self.tar.y-self:pull_min_y()),4)
			end

			--lock to edge
			if(self.pos.x<self.pos_min.x)self.pos.x=self.pos_min.x
			if(self.pos.x>self.pos_max.x)self.pos.x=self.pos_max.x
			if(self.pos.y<self.pos_min.y)self.pos.y=self.pos_min.y
			if(self.pos.y>self.pos_max.y)self.pos.y=self.pos_max.y
		end,

		cam_pos=function(self)
			--calculate camera shake.
			local shk=m_vec(0,0)
			if self.shake_remaining>0 then
				shk.x=rnd(self.shake_force)-(self.shake_force/2)
				shk.y=rnd(self.shake_force)-(self.shake_force/2)
			end
			return self.pos.x-64+shk.x,self.pos.y-64+shk.y
		end,

		pull_max_x=function(self)
			return self.pos.x+self.pull_threshold
		end,

		pull_min_x=function(self)
			return self.pos.x-self.pull_threshold
		end,

		pull_max_y=function(self)
			return self.pos.y+self.pull_threshold
		end,

		pull_min_y=function(self)
			return self.pos.y-self.pull_threshold
		end,
		
		shake=function(self,ticks,force)
			self.shake_remaining=ticks
			self.shake_force=force
		end
	}

	return c
end
-->8
-- player

--make the player
function m_player(x,y)

	--todo: refactor with m_vec.
	local p=
	{
		x=x,
		y=y,

		dx=0,
		dy=0,

		w=8,
		h=8,
		
		max_dx=1,--max x speed
		max_dy=2,--max y speed

		jump_speed=-1.75,--jump veloclity
		acc=0.05,--acceleration
		dcc=0.8,--decceleration
		air_dcc=1,--air decceleration
		grav=0.15,
		
		--helper for more complex
		--button press tracking.
		--todo: generalize button index.
		jump_button=
		{
			update=function(self)
				--start with assumption
				--that not a new press.
				self.is_pressed=false
				if btn(5) then
					if not self.is_down then
						self.is_pressed=true
					end
					self.is_down=true
					self.ticks_down+=1
				else
					self.is_down=false
					self.is_pressed=false
					self.ticks_down=0
				end
			end,
			--state
			is_pressed=false,--pressed this frame
			is_down=false,--currently down
			ticks_down=0,--how long down
		},

		jump_hold_time=0,--how long jump is held
		min_jump_press=5,--min time jump can be held
		max_jump_press=15,--max time jump can be held

		jump_btn_released=true,--can we jump again?
		grounded=false,--on ground

		airtime=0,--time since grounded
		
		--animation definitions.
		--use with set_anim()
		anims=
		{
			["stand"]=
			{
				ticks=5,--how long is each frame shown.
				frames={1,6},--what frames are shown.
			},
			["walk"]=
			{
				ticks=5,
				frames={1,2},
			},
			["jump"]=
			{
				ticks=1,
				frames={5},
			},
			["slide"]=
			{
				ticks=1,
				frames={5},
			},
			["sit"]=
			{
			 ticks=5,
			 frames={3,4},
			},
		},

		curanim="walk",--currently playing animation
		curframe=1,--curent frame of animation.
		animtick=0,--ticks until next frame should show.
		flipx=false,--show sprite be flipped.
		
		sat=false,
		
		--request new animation to play.
		set_anim=function(self,anim)
			if(anim==self.curanim)return--early out.
			local a=self.anims[anim]
			self.animtick=a.ticks--ticks count down.
			self.curanim=anim
			self.curframe=1
		end,
		
		--call once per tick.
		update=function(self)
	
			--todo: kill enemies.
			
			--track button presses
			local bl=btn(0) --left
			local br=btn(1) --right
			local bd=btn(3) --down
			
			--move left/right
			if bl==true then
				self.dx-=self.acc
				br=false--handle double press
			elseif br==true then
				self.dx+=self.acc
			else
				if self.grounded then
					self.dx*=self.dcc
				else
					self.dx*=self.air_dcc
				end
			end

			--limit walk speed
			self.dx=mid(-self.max_dx,self.dx,self.max_dx)
			
			--move in x
			self.x+=self.dx
			
			--hit walls
			collide_side(self)

			--jump buttons
			self.jump_button:update()
			
			--jump is complex.
			--we allow jump if:
			--	on ground
			--	recently on ground
			--	pressed btn right before landing
			--also, jump velocity is
			--not instant. it applies over
			--multiple frames.
			if self.jump_button.is_down then
				--is player on ground recently.
				--allow for jump right after 
				--walking off ledge.
				local on_ground=(self.grounded or self.airtime<5)
				--was btn presses recently?
				--allow for pressing right before
				--hitting ground.
				local new_jump_btn=self.jump_button.ticks_down<10
				--is player continuing a jump
				--or starting a new one?
				if self.jump_hold_time>0 or (on_ground and new_jump_btn) then
					--if(self.jump_hold_time==0)sfx(snd.jump)--new jump snd
					self.jump_hold_time+=1
					--keep applying jump velocity
					--until max jump time.
					if self.jump_hold_time<self.max_jump_press then
						self.dy=self.jump_speed--keep going up while held
					end
				end
			else
				self.jump_hold_time=0
			end
			
			--move in y
			self.dy+=self.grav
			self.dy=mid(-self.max_dy,self.dy,self.max_dy)
			self.y+=self.dy

			--floor
			if not collide_floor(self) then
				self:set_anim("jump")
				self.grounded=false
				self.airtime+=1
			end

			--roof
			collide_roof(self)

			--handle playing correct animation when
			--on the ground.
			self.sat=false
			if self.grounded then
				if br then
					if self.dx<0 then
						--pressing right but still moving left.
						self:set_anim("slide")
					else
						self:set_anim("walk")
					end
				elseif bl then
					if self.dx>0 then
						--pressing left but still moving right.
						self:set_anim("slide")
					else
						self:set_anim("walk")
					end
				elseif bd then
				 self:set_anim("sit")
				 self.sat=true
				else
					self:set_anim("stand")
				end
			end

			--flip
			if br then
				self.flipx=false
			elseif bl then
				self.flipx=true
			end

			--anim tick
			self.animtick-=1
			if self.animtick<=0 then
				self.curframe+=1
				local a=self.anims[self.curanim]
				self.animtick=a.ticks--reset timer
				if self.curframe>#a.frames then
					self.curframe=1--loop
				end
			end

  if (self.x<20) self.x=20
  if (self.x>237) self.x=237

		end,

		--draw the player
		draw=function(self)
			local a=self.anims[self.curanim]
			local frame=a.frames[self.curframe]
			palt(0,false)
			palt(7,true)
			spr(frame,
				self.x-(self.w/2),
				self.y-(self.h/2),
				self.w/8,self.h/8,
				self.flipx,
				false)
			palt(0,true)
			palt(7,false)
		end,
	}

	return p
end

-->8
-- util

--sfx
snd=
{
	bark=0,
	come=1,
	fetch=2,
	sit=3,
}

--music tracks
mus=
{

}

--math
--------------------------------

--point to box intersection.
function intersects_point_box(px,py,x,y,w,h)
	if flr(px)>=flr(x) and flr(px)<flr(x+w) and
				flr(py)>=flr(y) and flr(py)<flr(y+h) then
		return true
	else
		return false
	end
end

--box to box intersection
function intersects_box_box(
	x1,y1,
	w1,h1,
	x2,y2,
	w2,h2)

	local xd=x1-x2
	local xs=w1*0.5+w2*0.5
	if abs(xd)>=xs then return false end

	local yd=y1-y2
	local ys=h1*0.5+h2*0.5
	if abs(yd)>=ys then return false end
	
	return true
end

--check if pushing into side tile and resolve.
--requires self.dx,self.x,self.y, and 
--assumes tile flag 0 == solid
--assumes sprite size of 8x8
function collide_side(self)

	local offset=self.w/3
	for i=-(self.w/3),(self.w/3),2 do
	--if self.dx>0 then
		if fget(mget((self.x+(offset))/8,(self.y+i)/8),0) then
			self.dx=0
			self.x=(flr(((self.x+(offset))/8))*8)-(offset)
			return true
		end
	--elseif self.dx<0 then
		if fget(mget((self.x-(offset))/8,(self.y+i)/8),0) then
			self.dx=0
			self.x=(flr((self.x-(offset))/8)*8)+8+(offset)
			return true
		end
--	end
	end
	--didn't hit a solid tile.
	return false
end

--check if pushing into floor tile and resolve.
--requires self.dx,self.x,self.y,self.grounded,self.airtime and 
--assumes tile flag 0 or 1 == solid
function collide_floor(self)
	--only check for ground when falling.
	if self.dy<0 then
		return false
	end
	local landed=false
	--check for collision at multiple points along the bottom
	--of the sprite: left, center, and right.
	for i=-(self.w/3),(self.w/3),2 do
		local tile=mget((self.x+i)/8,(self.y+(self.h/2))/8)
		if fget(tile,0) or (fget(tile,1) and self.dy>=0) then
			self.dy=0
			self.y=(flr((self.y+(self.h/2))/8)*8)-(self.h/2)
			self.grounded=true
			self.airtime=0
			landed=true
		end
	end
	return landed
end

--check if pushing into roof tile and resolve.
--requires self.dy,self.x,self.y, and 
--assumes tile flag 0 == solid
function collide_roof(self)
	--check for collision at multiple points along the top
	--of the sprite: left, center, and right.
	for i=-(self.w/3),(self.w/3),2 do
		if fget(mget((self.x+i)/8,(self.y-(self.h/2))/8),0) then
			self.dy=0
			self.y=flr((self.y-(self.h/2))/8)*8+8+(self.h/2)
			self.jump_hold_time=0
		end
	end
end

--make 2d vector
function m_vec(x,y)
	local v=
	{
		x=x,
		y=y,
		
  --get the length of the vector
		get_length=function(self)
			return sqrt(self.x^2+self.y^2)
		end,
		
  --get the normal of the vector
		get_norm=function(self)
			local l = self:get_length()
			return m_vec(self.x / l, self.y / l),l;
		end,
	}
	return v
end

--square root.
function sqr(a) return a*a end

--round to the nearest whole number.
function round(a) return flr(a+0.5) end


--utils
--------------------------------

--print string with outline.
function printo(str,startx,
															 starty,col,
															 col_bg)
	print(str,startx+1,starty,col_bg)
	print(str,startx-1,starty,col_bg)
	print(str,startx,starty+1,col_bg)
	print(str,startx,starty-1,col_bg)
	print(str,startx+1,starty-1,col_bg)
	print(str,startx-1,starty-1,col_bg)
	print(str,startx-1,starty+1,col_bg)
	print(str,startx+1,starty+1,col_bg)
	print(str,startx,starty,col)
end

--print string centered with 
--outline.
function printc(
	str,x,y,
	col,col_bg,
	special_chars)

	local len=(#str*4)+(special_chars*3)
	local startx=x-(len/2)
	local starty=y-2
	printo(str,startx,starty,col,col_bg)
end
-->8
-- text

function m_text(x,y,text)
 local t={
  x=x,
  y=y,
  text=text,
  colours={10,11,14,15},
  c=9,
  tick=0,
  frame=0,
  
  update=function(self)
   self.tick+=1
   if self.tick>4 then
    self.tick=0
    self.frame+=1
    if self.frame<#self.colours then
     self.x+=1
     self.y-=1
     self.c=self.colours[self.frame]
    end
   end
   return self.frame<5
  end,
  
  draw=function(self)
   print(self.text,self.x,self.y,self.c)
  end,
 }
 add(texts,t)
 return t
end

texts={}
function update_texts()
 for t in all(texts) do
  if not t:update() then
   del(texts,t)
  end
 end
end

function draw_texts()
 for t in all(texts) do
  t:draw()
 end
 camera(0,0)
 print("score: "..game.score,2,2,1)
end
__gfx__
000000007777777777777777777777777777777777f77f77777777773b3b3b3b44444444b3b3b3b33b3b3b3b4444444455555555cccccccc7676767677777777
0000000077f77f7777f77f7777777777777777777744447777f77f77b3b3b3b3444444443b3b3b3bb3b3b3b34445444455555555cccccccc6767676777777777
00700700774444777744447777f77f7777f77f7777440457774444773333333344454444b33333333333333b4444444455555555ccccccccc6c6c6c677777777
0007700077440457774404577744447777444477574448777744045733333333445444443b333333333333b34444444455555555cccccccc6c6c6c6c77777777
00077000774448775744487777440457774404577444ff77574448774444444444444444b33344444444333b5454545455555555cccccccccccccccc77777777
007007005444ff777444ff777744487757444877774444777444ff7744544444444444443b334544445433b34545454505050505ccccccccc6ccc6cc77777777
0000000077444477774444575444ff777444ff7775777757774444774444444444444454b33344444444333b5555555550505050cccccccccccccccc77777777
0000000077577577777577777744447777444477777777777757757744444444444444443b334444444433b35555555500000000ccccccccccc6ccc677777777
0000000000004440000000000000444000000000cccccccccccccccccccccccccc6767cccccccccc000000000000000000000000000000000000000000000000
0000000000004ff00000000000004ff000ff0000ccccccccccccccccccccccccc676776ccccccccc000000000000000000000000000000000000000000000000
000000000000fff0000000000000fff002ff0000555cccccccccc6767676777777777777676ccccc000000000000000000000000000000000000000000000000
000000000000fff0000000000000fff022200000595ccccccccc6c67776767777777777776c6cccc000000000000000000000000000000000000000000000000
00000000000022200000000000002222220000009f9cccccccccc6777777777777777777776ccccc000000000000000000000000000000000000000000000000
000000000022222220000000002222ee20000000599cccccc6c67777777776767776767677776c6c000000000000000000000000000000000000000000000000
00000000002eeeee20000000002eeee2000000009f9ccccc6c67777777776767776c6c67777776c6000000000000000000000000000000000000000000000000
00000000002eeeee20000000002eeee200000000599ccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
00000000002222222000000000222222000000009f9ccccccccccccccccccccc4444445400000000000000000000000000000000000000000000000000000000
0000000000211111200000000021111100000000599ccccccccccccccccccccc4444444400000000000000000000000000000000000000000000000000000000
00000000002f111f20000000002f1111000000009f9ccccccccccccccccccccc44544f4400000000000000000000000000000000000000000000000000000000
0000000000ff101ff000000000ff101100000000599ccccccccccccccccccccc4444454400000000000000000000000000000000000000000000000000000000
00000000000110110000000000011011000000009f9ccccccccccccccccccccc4454444400000000000000000000000000000000000000000000000000000000
0000000000011011000000000001101100000000599ccccccccceccccccccccc45f4444400000000000000000000000000000000000000000000000000000000
00000000000550550000000000055055000000009f9cccccccbebcbccbec3b3c4544445400000000000000000000000000000000000000000000000000000000
0000000000055555500000000005555550000000599ccccccbcb3bccbeb3b3bc4444444400000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3b3b3b3b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3b3b3b3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44544444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000001010101010100000000010001000100000000000000000000000100010001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d1617190d150d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d161718190d0d0d0d0d0d0d0d161818190d0d0d0d0d250d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d1617190d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d2727250d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d161817190d0d0d0d26090707070a0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d270907080808070a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0d0d0d0d0d0d0d0d0d0d0d0d0d0d0d270d0d0d0d0d0d0d0d0907080828280808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a0d270d0d0d260d0d0d0d0d0d260907070a0d2627260d090708082828282808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07070707070707070a0d270d0d09070808070707070707070808282828282808000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0808082808280808070707070707082828280808280808080828282828282828000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00030000024170642709457104571e457084270341703417034000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400004000040000400
000f00003b0243905137011360002d000140001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000039014370513505137021390110800008000160000b0000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000002603426051240512401500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
