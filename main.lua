-- Define game states.
local state = { isMenu = true, isOver = false }

-- Define data values for individual plants.
plant_health = {}
plant_status = {}

function love.load()
	-- Set game values.
	love.window.setTitle("Extreme Farming")
	love.graphics.setBackgroundColor(255, 255, 255, 255)
	-- (Broken) love.graphics.setIcon(icon)
	love.mouse.setVisible(false)

	-- Preload sprites for use.
	flower_alive = love.graphics.newImage("assets/images/sprites/sprite-flower.png")
	flower_dead = love.graphics.newImage("assets/images/sprites/sprite-flower-dead.png")
	flower_dying = love.graphics.newImage("assets/images/sprites/sprite-flower-dying.png")
	flower_sieged = love.graphics.newImage("assets/images/sprites/sprite-flower-sieged.png")
	flower_critical = love.graphics.newImage("assets/images/sprites/sprite-flower-critical.png")
	rain = love.graphics.newImage("assets/images/sprites/sprite-rain.png")
	faucet = love.graphics.newImage("assets/images/sprites/sprite-faucet.png")
	bucket = love.graphics.newImage("assets/images/sprites/sprite-bucket.png")
	sun = love.graphics.newImage("assets/images/sprites/sprite-sun.png")
	sprinkler = love.graphics.newImage("assets/images/sprites/sprite-sprinkler.png")
	swatter = love.graphics.newImage("assets/images/sprites/sprite-swatter.png")

	-- Preload images for use.
	mouse = love.graphics.newImage("assets/images/mouse.png")

	-- Preload bings for use.
	bing = love.audio.newSource("assets/sounds/bing.wav", "static")
	bees = love.audio.newSource("assets/sounds/bees.wav", "static")
	music = love.audio.newSource("assets/sounds/music.mp3", "stream")

	DefineVariables()
	
	-- Play the background music in a loop.
	music:setVolume(0.01)
	music:setLooping(true)
	music:play()
end

function DefineVariables()
	-- Make sure timers are set properly.
	time = love.timer.getTime()
	start = time
	daycycle = time + 30
	autowater = time
	attacks = time + 10

	-- Define variables.
	daylight = true
	multiplier = 0.5
	score = 0
	water = 250
	seeds = 10
	faucetuses = 5
	sprinklers = 0
	swatts = 10

	-- Define plant variables.
	for y = 1, 5 do       
		plant_health[y] = {}
		plant_status[y] = {}

		for x = 1, 5 do
			plant_health[y][x] = 100
			plant_status[y][x] = 0
		end
	end
end

function love.update(dt)
	if state.isMenu then return end

	-- Stop the game if it's over.
	if state.isOver then return end

	local time = love.timer.getTime()

	if time > start then

		start = time + multiplier
		local total = 0

		for i = 1, 5 do
			for x = 1, 5 do
				if plant_health[i][x] > 0 then
					if plant_status[i][x] == 2 then
						plant_health[i][x] = plant_health[i][x] - 3;
					elseif plant_status[i][x] == 1 then
						plant_health[i][x] = plant_health[i][x] - 2;
					elseif plant_status[i][x] == 0 then
						plant_health[i][x] = plant_health[i][x] - 1;
					end
				end
				
				--Should never go below 0 health.
				if plant_health[i][x] < 0 then
					plant_health[i][x] = 0
				end

				if plant_health[i][x] < 1 then
					total = total + 1
				end
			end
		end

		if total == 25 then
			state.isOver = true
		end

		if daylight then
			multiplier = multiplier - 0.002
		end
	end

	if time > daycycle then
		daycycle = time + 30
		daylight = not daylight

		if daylight then
			water = water + 100
			faucetuses = faucetuses + 5
			swatts = swatts + 10
		end
	end

	if daylight and time > autowater then
		autowater = time + 2
		
		if sprinklers > 0 then
			for i = 1, 5 do
				for x = 1, 5 do
					plant_health[i][x] = plant_health[i][x] + sprinklers * 2
				end
			end
		end
	end

	if time > attacks then
		attacks = time + 10

		for i = 1, 5 do
			for x = 1, 5 do
				if plant_status[i][x] == 0 then
					if love.math.random(0, 100) > 98 then
						plant_status[i][x] = 2
					elseif love.math.random(0, 100) > 93 then
						plant_status[i][x] = 1
					end
				end
			end
		end

		love.audio.play(bees)
	end
end

function love.draw()
	if state.isMenu then
		love.graphics.setFont(love.graphics.newFont(64))
		DrawText("Extreme Farmers", 10, 10)

		love.graphics.setFont(love.graphics.newFont(32))
		DrawText("Play", 10, 120)
		DrawText("Quit", 10, 160)
		DrawText("V. 3.0.0", 670, 550)
		love.graphics.setFont(love.graphics.newFont(12))

		x, y = love.mouse.getPosition()
		love.graphics.draw(mouse, x, y)

		return
	end

	if state.isOver then
		DrawText("Game Over", 400, 10)

		x, y = love.mouse.getPosition()
		love.graphics.draw(mouse, x, y)

		return
	end

	--Draw flowers so that they show up on screen.
	for i = 1, 5 do
		for x = 1, 5 do
			if plant_status[i][x] == 2 then
				love.graphics.draw(flower_critical, i * 100, x * 100)
			elseif plant_status[i][x] == 1 then
				love.graphics.draw(flower_sieged, i * 100, x * 100)
			elseif plant_status[i][x] == 0 then

				if plant_health[i][x] >= 50 then
					love.graphics.draw(flower_alive, i * 100, x * 100)
				elseif plant_health[i][x] >= 1 then
					love.graphics.draw(flower_dying, i * 100, x * 100)
				elseif plant_health[i][x] <= 0 then
					love.graphics.draw(flower_dead, i * 100, x * 100)
				end

			end
			
			DrawText(plant_health[i][x], i * 100 + 8, x * 100 + 35)
		end
	end

	x, y = love.mouse.getPosition()

	for a = 1, 5 do
		for b = 1, 5 do
			if x >= a * 100 and x <= a * 100 + 32 and y >= b * 100 and y <= b * 100 + 32 then
				DrawText("Interact with Plant (Water/Swat Bees)", 400, 10)
			end
		end
	end

	--Click detection for rain, SEND HELP HOLY...
	if x >= 665 and x <= 665 + 32 and y >= 450 and y <= 450 + 32 then
		DrawText("Pray for Rain (Mass Watering)", 400, 10)
	end

	--Click detection for the faucet, SEND HELP HOLY...
	if x >= 665 and x <= 665 + 32 and y >= 400 and y <= 400 + 32 then
		DrawText("Refill your Water (Adds to your water gauge)", 400, 10)
	end

	--Click detection for the bucket, SEND HELP HOLY...
	if x >= 25 and x <= 25 + 32 and y >= 25 and y <= 25 + 32 then
		DrawText("Interact with All Plants (Click on them all)", 400, 10)
	end

	--Click detection for the sprinklers, SEND HELP HOLY...
	if x >= 665 and x <= 665 + 32 and y >= 350 and y <= 350 + 32 then
		DrawText("Fill a Sprinkler (Autoregen Plants)", 400, 10)
	end

	--Click detection for the swatter, SEND HELP HOLY...
	if x >= 665 and x <= 665 + 32 and y >= 310 and y <= 310 + 32 then
		DrawText("Swat away Flies (Not Clickable)", 400, 10)
	end

	love.graphics.draw(bucket, 25, 25)
	love.graphics.draw(swatter, 665, 310)
	love.graphics.draw(sprinkler, 665, 350)
	love.graphics.draw(faucet, 665, 400)
	love.graphics.draw(rain, 665, 450)
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print("Score: " .. score, 650, 500)
	love.graphics.print("Water: " .. water, 650, 515)
	love.graphics.print("Seeds: " .. seeds, 650, 530)
	love.graphics.print(faucetuses, 700, 408)
	love.graphics.print(sprinklers, 700, 363)
	love.graphics.print(swatts, 700, 320)
	love.graphics.setColor(255, 255, 255, 255)

	if daylight then
		love.graphics.draw(sun, 768, 0)
		DrawText("Day", 775, 40)
	else
		DrawText("Night", 766, 40)
	end

	--Goes at the bottom so it draws over everything.
	love.graphics.draw(mouse, x, y)
end

function love.mousepressed(x, y, button, istouch)
	if button == 1 then
		if state.isMenu then
			--Play
			if x >= 10 and x <= 10 + 64 and y >= 120 and y <= 120 + 32 then
				DefineVariables()
				state.isMenu = false
			end
			--Quit
			if x >= 10 and x <= 10 + 64 and y >= 160 and y <= 160 + 32 then
				love.event.quit()
			end
			return
		end

		--Click detection for flowers, SEND HELP HOLY...
		for a = 1, 5 do
			for b = 1, 5 do
				if x >= a * 100 - 16 and x <= a * 100 + 38 and y >= b * 100 - 16 and y <= b * 100 + 38 then
					love.audio.play(bing)
					
					if plant_health[a][b] > 0 then
						if plant_status[a][b] == 2 then
							if swatts > 2 then
								plant_status[a][b] = 0
								swatts = swatts - 2
							end
						elseif plant_status[a][b] == 1 then
							if swatts > 1 then
								plant_status[a][b] = 0
								swatts = swatts - 1
							end
						elseif plant_status[a][b] == 0 then
							if water > 0 then
								plant_health[a][b] = plant_health[a][b] + 25
								score = score + 1
								water = water - 1
							end
						end
						
					elseif seeds > 0 then
						plant_health[a][b] = 100
						seeds = seeds - 1
					end
				end
			end
		end

		--Click detection for rain, SEND HELP HOLY...
		if x >= 665 and x <= 665 + 32 and y >= 450 and y <= 450 + 32 then
			love.audio.play(bing)

			if water > 0 then
				for i = 1, 5 do
					for x = 1, 5 do
						plant_health[i][x] = plant_health[i][x] + 100
					end
				end

				water = 0
				score = score + 50
			end
		end

		--Click detection for the faucet, SEND HELP HOLY...
		if x >= 665 and x <= 665 + 32 and y >= 400 and y <= 400 + 32 then
			love.audio.play(bing)

			if faucetuses > 0 then
				water = water + 25
				faucetuses = faucetuses - 1
				score = score + 5
			end
		end

		--Click detection for the bucket, SEND HELP HOLY...
		if x >= 25 and x <= 25 + 32 and y >= 25 and y <= 25 + 32 then
			love.audio.play(bing)

			if water > 0 then
				for a = 1, 5 do
					for b = 1, 5 do
						if plant_health[a][b] > 0 then
							plant_health[a][b] = plant_health[a][b] + 25
							score = score + 20
							water = water - 1
						end
					end
				end
			end
		end
		
		--Click detection for the sprinkler, SEND HELP HOLY...
		if x >= 665 and x <= 665 + 32 and y >= 350 and y <= 350 + 32 then
			love.audio.play(bing)

			if water > 100 then
				water = water - 100
				sprinklers = sprinklers + 1
				score = score + 100
			end
		end
	end
end

--Simple function to draw text as black, I'm too stupid to figure out how to do it properly.
function DrawText(text, x, y)
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print(text, x, y)
	love.graphics.setColor(255, 255, 255, 255)
end

function love.keypressed(key)
	if key == "escape" then
		if state.isOver then
			state.isMenu = true
			state.isOver = false
		else
			love.event.quit()
		end
	end
end