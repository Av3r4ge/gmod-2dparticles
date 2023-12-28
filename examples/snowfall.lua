local scrw, scrh = ScrW(), ScrH()

local snowcanvas = gmparticles.canvas:new(scrw, scrh + 20 ) -- create canvas of user's screen plus some extra so snow can come from above the screen
local snowflakedir = 180 -- move downwards
local frequency = 0.2 -- how many times a second snowflakes are created

timer.Create("SnowParticle", frequency, 0, function()
	local snowflake = gmparticles.particle:new( math.random(0, scrw), 0 ) -- make new particle randomly accross screen
	snowflake:setsize( math.random(10, 12) )
	snowflake:setmove( math.random(50, 100), snowflakedir )
	snowflake:setspin( math.random(15, 50) )
	snowflake:setalpha( math.random(150, 200) )

	snowcanvas:addparticle(snowflake) -- add the particle to canvas to render
end)

hook.Add("HUDPaint", "paintsnowflakes", function() -- paint it!
	snowcanvas:draw(0,-20)
end)