if not CLIENT then return end

math = math
surface = surface
pairs = pairs
setmetatable = setmetatable

gmparticles = gmparticles or {}
gmparticles.version = "v0.12"

-- particles

gmparticles.particle = {}
gmparticles.particle.__index = gmparticles.particle

-- particle object
function gmparticles.particle:new(x, y)
	local particle = setmetatable({}, gmparticles.particle)

	particle.color = color_white
	particle.alpha = 255
	particle.mat = Material("vgui/white")

	particle.x = x
	particle.y = y

	particle.size = 35
	particle.rotation = 0

	return particle
end

function gmparticles.particle:setposition( x, y )
	if x and y then
		self.x = x
		self.y = y 
	end
end

function gmparticles.particle:setsize( size )
	if size then self.size = size end 
end

function gmparticles.particle:setspin( speed )
	if speed then self.rotation = speed end 
end

function gmparticles.particle:setrotation( angle )
	if angle then self.rotation = angle end 
end

function gmparticles.particle:setcolor( color )
	if IsColor(color) then self.color = color end
end

function gmparticles.particle:setalpha( alpha )
	if alpha then self.alpha = alpha end 
end

function gmparticles.particle:setmaterial( path )
	if path then Material(path) end
end

function gmparticles.particle:setmove( speed, direction )
	if direction and speed then
		self.speed = speed
		self.dir = direction
	end
end

function gmparticles.particle:ondestroy()
end
 
function gmparticles.particle:modify() -- allows you to modify your particle during the drawing frame
end

-- canvas

gmparticles.canvas = {}
gmparticles.canvas.__index = gmparticles.canvas

-- object that contains particles
function gmparticles.canvas:new(width, height)
	local canvas = setmetatable({}, gmparticles.canvas)

	canvas.particles = {}

	canvas.w = width 
	canvas.h = height

	return canvas
end

-- makes all particles go towards specificed direction
function gmparticles.canvas:setgravity( force, direction )

end

-- makes all particles slow down
function gmparticles.canvas:setfriction( amount )

end

function gmparticles.canvas:addparticle( obj )
	self.particles[ #self.particles + 1 ] = obj
end

function gmparticles.canvas:getparticles()
	return self.particles
end

local degreetorad = (math.pi / 180)

function gmparticles.canvas:draw(x, y)

	-- we only want to do the particle caluclations if the canvas is being drawn
	for n, prt in pairs( self.particles ) do

		-- move particle towards current direction
		if (prt.dir) and (prt.speed > 0) then 
			prt.x = prt.x + ( (FrameTime() * prt.speed) * math.cos( (prt.dir - 90) * degreetorad ) )
			prt.y = prt.y + ( (FrameTime() * prt.speed) * math.sin( (prt.dir - 90) * degreetorad ) )

			-- friction
			if (self.friction) and (self.friction > 0) then prt.speed = prt.speed - (FrameTime() * self.friction) end
		end

		-- move particle towards canvas gravity
		if ( self.gravitydir ) and ( self.gravityforce > 0 ) then
			prt.x = prt.x + ( (FrameTime() * self.gravityforce) * math.cos( (self.gravitydir - 90) * degreetorad ) )
			prt.y = prt.y + ( (FrameTime() * self.gravityforce) * math.sin( (self.gravitydir - 90) * degreetorad ) )
		end

		if (prt.spinspeed) then prt.rotation = prt.rotation + (FrameTime() * prt.spinspeed) end -- spin
		if (prt.growspeed) and (prt.growspeed > 0) then prt.size = math.Clamp(prt.size + (FrameTime() * prt.growspeed), 0, prt.maxgrowsize or math.max(self.w, self.h)) end -- grow size 
		if (prt.fadespeed) then prt.alpha = math.Clamp(prt.alpha - (FrameTime() * prt.fadespeed), prt.minalpha or 0, prt.maxalpha or 255) end -- fade speed


		-- allow user to modify the particle
		prt:modify()

		-- draw the particle
		surface.SetDrawColor( prt.color.r, prt.color.g, prt.color.b, prt.alpha )
		surface.SetMaterial( prt.mat )
		surface.DrawTexturedRectRotated( (x + prt.x), (y + prt.y), prt.size, prt.size, prt.rotation or 0 )

		-- handle removing particle

		if (prt.lifetime) and (CurTime() > prt.lifetime) then
			prt:ondestroy(prt.x, prt.y)
			self.particles[n] = nil
		end

		if ( (prt.x - prt.size) > self.w ) or ( (prt.x + prt.size) < x ) or ( (prt.y - prt.size) > self.h ) or ( (prt.y + prt.size) < y ) then -- offscreen
			prt:ondestroy(prt.x, prt.y)
			self.particles[n] = nil
		end

	end

end
