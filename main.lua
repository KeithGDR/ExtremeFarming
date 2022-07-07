local start = love.timer.getTime()
planet_values = {}

function love.load()
	love.window.setTitle("Extreme Farming")
	-- love.graphics.setBackgroundColor(255, 255, 255, 255)
	-- love.graphics.setIcon("")
	flower = love.graphics.newImage("assets/sprite-flower.png")
	flower_dead = love.graphics.newImage("assets/sprite-flower-dead.png")
	flower_dying = love.graphics.newImage("assets/sprite-flower-dying.png")
	rain = love.graphics.newImage("assets/rain.png")

	--variables
	multiplier = 0.5
	score = 0
	water = 100
	seeds = 10

	for y = 1, 5 do       
		planet_values[y] = {}
		for x = 1, 5 do
			planet_values[y][x] = 100
		end
	end
end

function love.update(dt)
	local end_game = true

	if love.timer.getTime() > start then
		start = love.timer.getTime() + multiplier
		for i = 1, 5 do
			for x = 1, 5 do
				planet_values[i][x] = planet_values[i][x] - 1;

				if planet_values[i][x] > 0 then
					end_game = false
				end
			end
		end
		multiplier = multiplier - 0.01
		if end_game then
			love.event.quit()
		end
	end
end

function love.draw()
	--Draw flowers so that they show up on screen.
	for i = 1, 5 do
		for x = 1, 5 do
			if planet_values[i][x] > 0 then
				love.graphics.draw(flower, i * 100, x * 100)
			elseif planet_values[i][x] <= 50 then
				love.graphics.draw(flower_dying, i * 100, x * 100)
			elseif planet_values[i][x] <= 0 then
				love.graphics.draw(flower_dead, i * 100, x * 100)
			end
			love.graphics.print(planet_values[i][x], i * 100 + 5, x * 100 + 35)
		end
	end

	love.graphics.draw(rain, 665, 450)
	love.graphics.print("Score: " .. score, 650, 500)
	love.graphics.print("Water: " .. water, 650, 515)
	love.graphics.print("Seeds: " .. seeds, 650, 530)
end

function love.mousepressed(x, y, button, istouch)
	if button == 1 then
		--Click detection for flowers, SEND HELP HOLY...
		for a = 1, 5 do
			for b = 1, 5 do
				if x >= a * 100 and x <= a * 100 + 32 and y >= b * 100 and y <= b * 100 + 32 then
					if planet_values[a][b] > 0 then
						planet_values[a][b] = planet_values[a][b] + 25
						score = score + 1
					end
				end
			end
		end

		--Click detection for rain, SEND HELP HOLY...
		if x >= 665 and x <= 665 + 32 and y >= 450 and y <= 450 + 32 then
			if water > 0 then
				water = water - 25
				for i = 1, 5 do
					for x = 1, 5 do
						planet_values[i][x] = planet_values[i][x] + 100
					end
				end
			end
		end
	end
end