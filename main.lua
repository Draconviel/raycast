function love.load()

	screen = {}
	screen.width = 1080
	screen.height = 720
	love.window.setMode(screen.width,screen.height)

	function heightMap3d(x,y,size,zoom,detail,seed,perc)
		x = x/(size*zoom)
		y = y/(size*zoom)
		if not perc then
			perc = 0.75
		end
	return(
		(love.math.noise(x,y,seed)*(1-perc))+(love.math.noise(x*detail,y*detail,seed*detail)*perc)
		)
	end

	function distance( x1, y1, x2, y2 )
		return math.sqrt( (x2-x1)^2 + (y2-y1)^2 )
	end

	function physics(object,dt)
		if object == player then
			if map[math.floor((map.width/2)+(object.xvel*dt))][math.floor((map.width/2)+(object.yvel*dt))] == 1 then
				object.xvel = -(object.xvel/2)
				object.yvel = -(object.yvel/2)
			end
		else
			if map[math.floor(object.x+(object.xvel*dt))][math.floor(object.y+(object.yvel*dt))] == 1 then
				object.xvel = -(object.xvel/2)
				object.yvel = -(object.yvel/2)
			end
		end
		object.x = object.x+(object.xvel*dt)
		object.y = object.y+(object.yvel*dt)
		if object.xvel > 0 then
			object.xvel = object.xvel - (object.friction*dt)
		elseif object.xvel < 0 then
			object.xvel = object.xvel + (object.friction*dt)
		end
		if object.yvel > 0 then
			object.yvel = object.yvel - (object.friction*dt)
		elseif object.yvel < 0 then
			object.yvel = object.yvel + (object.friction*dt)
		end
		if math.abs(object.yvel) < (object.friction*dt) then
			object.yvel = 0
		end
		if math.abs(object.xvel) < (object.friction*dt) then
			object.xvel = 0
		end

	end

	player = {}
	player.x = 90
	player.y = 90
	player.xvel = 0
	player.yvel = 0
	player.dir = 0
	player.speed = 480
	player.friction = 30
	player.turnspeed = math.pi*2
	player.rays = 1080
	player.range = 90
	player.dist = 256
	player.sight = {}
	--player.sightcol = {}

	minimap = {}
	minimap.color = {1,1,0.5}
	minimap.altcolor = {1,0,1}
	minimap.scale = 4

	map = {}
	--map.color = {}
	mapsee = {}
	map.width = 512
	for x=1,map.width do
		map[x] = {}
		--map.color[x] = {}
		mapsee[x] = {}
		for y=1,map.width do
			map[x][y] = math.floor(heightMap3d(x,y,map.width,1,4,1337,0.75)+0.5)
			--map.color[x][y] = {heightMap3d(x,y,map.width,1,4,1337,0.75),heightMap3d(x^2,y/2,map.width,1,4,1337,0.75),heightMap3d(x/2,y^2,map.width,1,4,1337,0.75)}
			mapsee[x][y] = 0
		end
	end

	texture = love.graphics.newImage("test.png")
	samples = {}
	for i = 1, texture:getWidth() do
		local max = texture:getWidth()
		samples[i] = love.graphics.newQuad((i-1),0,1,max,max,max)
	end
	love.mouse.setGrabbed(true)
	love.mouse.setRelativeMode(true)
	function love.mousemoved( x, y, dx, dy, istouch )
		player.dir = player.dir+((dx/screen.width)*player.turnspeed)
	end
end
function love.update(dt)
	-- for x=1,map.width do
	-- 	map.color[x] = {}
	-- 	for y=1,map.width do
	-- 		if map[x][y] == 1 then
	-- 			map.color[x][y] = {heightMap3d(x,y,map.width,1,4,love.timer.getTime(),0.75),heightMap3d(x,y,map.width,1,4,love.timer.getTime()/2,0.75),heightMap3d(x,y,map.width,1,4,love.timer.getTime()*2,0.75)}
	-- 		end
	-- 	end
	-- end
	for x=1,map.width do
		map[x] = {}
		--map.color[x] = {}
		mapsee[x] = {}
		for y=1,map.width do
			map[x][y] = math.floor(heightMap3d(x+player.x,y+player.y,map.width,1,4,1337,0.75)+0.5)
			--map.color[x][y] = {heightMap3d(x,y,map.width,1,4,1337,0.75),heightMap3d(x^2,y/2,map.width,1,4,1337,0.75),heightMap3d(x/2,y^2,map.width,1,4,1337,0.75)}
			mapsee[x][y] = 0
		end
	end
	physics(player,dt)
	if love.keyboard.isDown("a") then
		player.xvel = math.sin(player.dir-math.rad(90))*(player.speed*dt)
		player.yvel = math.cos(player.dir-math.rad(90))*(player.speed*dt)
	end
	if love.keyboard.isDown("d") then
		player.xvel = math.sin(player.dir+math.rad(90))*(player.speed*dt)
		player.yvel = math.cos(player.dir+math.rad(90))*(player.speed*dt)
	end
	if love.keyboard.isDown("w") then
		player.xvel = math.sin(player.dir)*(player.speed*dt)
		player.yvel = math.cos(player.dir)*(player.speed*dt)
	end
	if love.keyboard.isDown("s") then
		player.xvel = math.sin(player.dir)*(-player.speed*dt)
		player.yvel = math.cos(player.dir)*(-player.speed*dt)
	end
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end
	for x=1,map.width do
		for y=1, map.width do
			mapsee[x][y] = 0
		end
	end
	for j=-player.rays/2,player.rays/2 do
		local out = false
		player.sight[j+player.rays/2] = 0
		--player.sightcol[j+player.rays/2] = {0,0,0}
		for i = 1,player.dist do
			px = ((map.width/2)+math.sin(player.dir+((j/player.rays)*math.rad(player.range)))*i)
			py = ((map.width/2)+math.cos(player.dir+((j/player.rays)*math.rad(player.range)))*i)
			if px > map.width or px < 1 or py > map.width or py < 1 then
				out = true
			end
			if px%1 > 0.5 then
				px = math.ceil(px)
			else
				px = math.floor(px)
			end
			if py%1 > 0.5 then
				py = math.ceil(py)
			else
				py = math.floor(py)
			end
			if not out then
				mapsee[px][py] = 1
				if map[(map.width/2)][(map.width/2)] == 0 then
					if map[px][py] == 1 then
						player.sight[j+player.rays/2] = ((player.dist-distance((map.width/2),(map.width/2),px,py))/player.dist) + (1/i)
						if map[math.floor((map.width/2)+(player.xvel*dt))][math.floor((map.width/2)+(player.yvel*dt))] == 1 then
							player.sight[j+player.rays/2] = 1
						end
						--player.sightcol[j+player.rays/2] = map.color[px][py]
						break
					end
				else
					player.sight[j+player.rays/2] = 1
				end
			end
		end
	end
end

function love.draw()
	love.graphics.push()
	love.graphics.translate(0,screen.height/2)
	for y=1,screen.height/2 do
		love.graphics.setColor(y/(screen.height/(112/255)*1.5),y/(screen.height/(34/255)*1.5),y/(screen.height/(255/255)*1.5))
		love.graphics.line(0,y,screen.width,y)
	end
	for i=1, player.rays do
		--love.graphics.setColor(player.sight[i]*player.sightcol[i][1],player.sight[i]*player.sightcol[i][2],player.sight[i]*player.sightcol[i][3])
		love.graphics.setColor(player.sight[i],player.sight[i],player.sight[i])
		love.graphics.rectangle("fill",(i-1)*(screen.width/player.rays),-(player.sight[i]*(screen.height/2)),(screen.width/player.rays),(player.sight[i]*(screen.height)))
		love.graphics.draw(texture,samples[(math.floor(i+player.dir)%texture:getWidth())+1],(i-1)*(screen.width/player.rays),-(player.sight[i]*(screen.height/2)),0,(screen.width/player.rays),(1/texture:getHeight())*(player.sight[i]*(screen.height)))
	end
	love.graphics.pop()
	love.graphics.push()
	love.graphics.translate((map.width/minimap.scale)/2,(map.width/minimap.scale)/2)
	love.graphics.rotate(player.dir)
	for x=1,map.width,math.floor(minimap.scale) do
		for y=1,map.width,math.floor(minimap.scale) do
			if distance(x,y,map.width/2,map.width/2) < map.width/2 then
				love.graphics.setColor(minimap.color[1],minimap.color[2],minimap.color[3],0.5)
				
				for j=-player.rays/2,player.rays/2 do

				end

				if map[x][y] == 1 then
					love.graphics.points(-(x-(map.width/2))/minimap.scale,-(y-(map.width/2))/minimap.scale)
				end
			end
		end
	end
	love.graphics.line(-math.sin(player.dir)*((map.width/4)/minimap.scale),-math.cos(player.dir)*((map.width/4)/minimap.scale),0,0)
	love.graphics.pop()
	-- love.graphics.setColor(1,1,0)
	-- love.graphics.circle("line",(map.width/2),(map.width/2),3)
	-- love.graphics.line((map.width/2),(map.width/2),(map.width/2)+(math.sin(player.dir)*player.speed*love.timer.getDelta()),(map.width/2)+(math.cos(player.dir)*player.speed*love.timer.getDelta()))
	love.graphics.setColor(1,1,1)
	love.graphics.print(player.rays)
end