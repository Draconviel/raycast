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

	function physics(object)
		object.x = object.x+object.xvel
		object.y = object.y+object.yvel
		if object.yvel > 0 then
			object.yvel = object.yvel - object.friction
		elseif object.yvel < 0 then
			object.yvel = object.yvel + object.friction
		end
		if object.yvel > 0 then
			object.yvel = object.yvel - object.friction
		elseif object.yvel < 0 then
			object.yvel = object.yvel + object.friction
		end
		if math.abs(object.yvel) < object.friction then
			object.yvel = 0
		end
		if math.abs(object.xvel) < object.friction then
			object.xvel = 0
		end
	end

	player = {}
	player.x = 0
	player.y = 0
	player.xvel = 0
	player.yvel = 0
	player.dir = 0
	player.speed = 60
	player.friction = 30
	player.turnspeed = 2
	player.rays = 1080
	player.range = 90
	player.dist = 180
	player.sight = {}

	map = {}
	mapsee = {}
	map.width = 180
	for x=1,map.width do
		map[x] = {}
		mapsee[x] = {}
		for y=1,map.width do
			map[x][y] = math.floor(heightMap3d(x,y,map.width,1,4,1337,0.75)+0.5)
			mapsee[x][y] = 0
		end
	end
end
function love.update(dt)
	physics(player)
	if love.keyboard.isDown("a") then
		player.dir = player.dir - (player.turnspeed*dt)
	end
	if love.keyboard.isDown("d") then
		player.dir = player.dir + (player.turnspeed*dt)
	end
	if love.keyboard.isDown("w") then
		player.xvel = math.sin(player.dir)*(player.speed*dt)
		player.yvel = math.cos(player.dir)*(player.speed*dt)
	end
	if love.keyboard.isDown("s") then
		player.xvel = math.sin(player.dir)*(-player.speed*dt)
		player.yvel = math.cos(player.dir)*(-player.speed*dt)
	end
	if love.keyboard.isDown("z") then
		player.range = player.range + 1
	end
	if love.keyboard.isDown("x") then
		player.range = player.range - 1
	end
	for x=1,map.width do
		for y=1, map.width do
			mapsee[x][y] = 0
		end
	end
	for j=-player.rays/2,player.rays/2 do
		local out = false
		player.sight[j+player.rays/2] = 0
		for i = 1,player.dist do
			px = (player.x+math.sin(player.dir+((j/player.rays)*math.rad(player.range)))*i)
			py = (player.y+math.cos(player.dir+((j/player.rays)*math.rad(player.range)))*i)
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
				if map[px][py] == 1 then
					player.sight[j+player.rays/2] = (player.dist-distance(player.x,player.y,px,py))/player.dist
					break
				end
			else
				player.sight[j+player.rays/2] = 0
			end
		end
	end
end
function love.draw()
	love.graphics.push()
	love.graphics.translate(0,screen.height/2)
	for i=1, player.rays do
		love.graphics.setColor(player.sight[i],player.sight[i],player.sight[i])
		love.graphics.rectangle("fill",(i-1)*(player.rays/screen.width),-(player.sight[i]*(screen.height/2)),(player.rays/screen.width),(player.sight[i]*(screen.height)))
	end
	love.graphics.pop()
	for x=1,map.width do
		for y=1,map.width do
			love.graphics.setColor(map[x][y],map[x][y],map[x][y])
			if mapsee[x][y] == 1 then
				love.graphics.setColor(0,map[x][y],0)
				if map[x][y] == 0 then
					love.graphics.setColor(0,0.5,0)
				end
			else
				love.graphics.setColor(map[x][y],0,0)
			end
			love.graphics.points(x,y)
		end
	end
	love.graphics.setColor(1,1,0)
	love.graphics.circle("line",player.x,player.y,3)
	love.graphics.line(player.x,player.y,player.x+(math.sin(player.dir)*player.speed),player.y+(math.cos(player.dir)*player.speed))
	love.graphics.setColor(1,1,1)
	love.graphics.print(player.range)
end