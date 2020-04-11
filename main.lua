pancake =  require "pancake"
function love.load()
	love.graphics.setBackgroundColor(0.1,0.1,0.1,1) --So it won't merge with pancake's background!!!
	pancake.init({window = {pixelSize = love.graphics.getHeight()/96, width = 96, height = 96}}) --Initiating pancake and setting pixelSize, so that the pancake display will be the height of the window! pixelSize is how many pixels every pancake pixel should take
	pancake.loadAnimation = nil
	pancake.paused = false
	--pancake.debugMode = true
	loadAssets()
	loadShipLevel()
	pancake.background.image = pancake.images.background
	left = pancake.addButton({key = "a", name="left",x = 1*pancake.window.pixelSize, y = love.graphics.getHeight()-16*pancake.window.pixelSize, width = 14, height = 14, scale = pancake.window.pixelSize})
	right = pancake.addButton({key = "d", name="right",x = 17*pancake.window.pixelSize, y = love.graphics.getHeight()-16*pancake.window.pixelSize, width = 14, height = 14, scale = pancake.window.pixelSize})
	up = pancake.addButton({key = "w", name="up",x = love.graphics.getWidth()-15*pancake.window.pixelSize, y = love.graphics.getHeight()-16*pancake.window.pixelSize, width = 14, height = 14, scale = pancake.window.pixelSize})
	down = pancake.addButton({key = "s", name="down",x = love.graphics.getWidth()-31*pancake.window.pixelSize, y = love.graphics.getHeight()-16*pancake.window.pixelSize, width = 14, height = 14, scale = pancake.window.pixelSize})
	center = pancake.addButton({func = centerPressed, key = "j", name="center",x = love.graphics.getWidth()-15*pancake.window.pixelSize, y = love.graphics.getHeight()-31*pancake.window.pixelSize, width = 14, height = 14, scale = pancake.window.pixelSize})
end

function loadAssets()
	--Adding buttons
	pancake.addImage("right", "images/ui")
	pancake.addImage("right_clicked", "images/ui")
	pancake.addImage("left", "images/ui")
	pancake.addImage("left_clicked", "images/ui")
	pancake.addImage("up", "images/ui")
	pancake.addImage("up_clicked", "images/ui")
	pancake.addImage("down", "images/ui")
	pancake.addImage("down_clicked", "images/ui")
	pancake.addImage("center", "images/ui")
	pancake.addImage("center_clicked", "images/ui")
	--Adding background (it will be more detailed later xD)
	pancake.addImage("background", "images")
	--Adding asteroids
	pancake.addImage("asteroid1", "images")
	pancake.addImage("asteroid2", "images")
	--Adding everything else
	pancake.addImage("laser", "images")
	--sounds
	pancake.addSound("laser")
end

function loadShipLevel(level)--level is a number of the level. This function loads everything that is needed for the ship levels
	pancake.objects = {}
	pancake.timers = {}
	pancake.physics.gravityY = 0
	ship = pancake.applyPhysics(pancake.addObject({name = "ship", x = 2, y = 64, width = 14, height = 9, offsetX = -1, offsetY = -5}))
	pancake.addAnimation("ship","idle","images/animations",180)
	pancake.changeAnimation(ship,"idle")
	levelType = "ship"-- This variable indicates what type of level are we in!
	pancake.cameraFollow = ship
	ship.maxVelocity = 70
	for w = 2, 40 do
		for i = 1, 5 do
			pancake.applyForce(createAsteroid(math.random(w*25,w*25+25), math.random(0,80), math.random(1,1)),{x=-math.random(0,7), y = math.random(-4,4), relativeToMass = true},1)
		end
	end
	createAsteroid(40, 40, 2)
end

function centerPressed()
	if levelType == "ship" then
		shoot()
	end
end

function createAsteroid(x,y,number)
	local ret
	if number == 1 then
		return pancake.applyPhysics(pancake.addObject({image = "asteroid1", name = "asteroid", x = x, y = y, width = 13, height = 13, offsetX = -2, offsetY = -1,layer = 2}))
	elseif number == 2 then
		return pancake.applyPhysics(pancake.addObject({image = "asteroid2", name = "asteroid", x = x, y = y, width = 10, height = 8, offsetX = -3, offsetY = -4,layer = 2}))
	end
end

function shoot()
	local laser = pancake.applyPhysics(pancake.addObject({name = "laser", x = ship.x + pancake.boolConversion(ship.flippedX, 0, 10), y = ship.y+2, height = 3, width = 8, image = "laser"}))
	pancake.applyForce(laser, {x = pancake.boolConversion(ship.flippedX, -1, 1)*200, relativeToMass = true}, 1)
	pancake.addTimer(600,"single",deleteLaser, laser)
	pancake.playSound("laser")
end

function deleteLaser(laser)
	pancake.trash(pancake.objects, laser.ID, "ID")
end

function pancake.onCollision() --This function will be called whenever a physic object collides with a colliding object!
	--Insert your amazing code here!
end

function pancake.onLoad() -- This function will be called when pancake start up is done (after the animation)
	--Insert your amazing code here!
end

function pancake.onOverlap(object1, object2, dt) -- This function will be called every time object "collides" with a non colliding object! Parameters: object1, object2 - objects of collision, dt - time of collision
	if object1.name == "ship" and object2.name == "asteroid" then
		pancake.trash(pancake.objects, "ship", "name")
	elseif object1.name == "laser" and object2.name == "asteroid" then
		pancake.trash(pancake.objects, object1.ID, "ID")
		pancake.trash(pancake.objects, object2.ID, "ID")
	end
end

function love.draw()
	pancake.draw() --Sets the canvas right! If pancake.autoDraw is set to true (which is its default state) the canvas will be automatically drawn on the window x and y
	pancake.print(#pancake.animations.ship.idle)
end

function love.update(dt)
	pancake.update(dt) --Passing time between frames to pancake!
	pancake.window.offsetY = 0 --So that our ship is followed only on x coordinate!
	pancake.window.offsetX = pancake.window.offsetX + 24
	if levelType == "ship" then
		if pancake.isButtonClicked(left) then
			pancake.applyForce(ship, {x = -25, relativeToMass = true})
			ship.flippedX = true
		end
		if pancake.isButtonClicked(right) then
			pancake.applyForce(ship, {x = 25, relativeToMass = true})
			ship.flippedX = false
		end
		if pancake.isButtonClicked(up) then
			pancake.applyForce(ship, {y = -25, relativeToMass = true})
		end
		if pancake.isButtonClicked(down) then
			pancake.applyForce(ship, {y = 25, relativeToMass = true})
		end
		if ship.y < 2 then
			ship.y = 2
			ship.velocityY = 0
		elseif ship.y > 86 then
			ship.y = 86
			ship.velocityY = 0
		end
		if ship.x < 0 then
			ship.x = 0
			ship.velocityX = 0
		end
	end
end

function love.mousepressed(x,y,button)
	pancake.mousepressed(x,y,button) -- Passing your presses to pancake!
end

function love.keypressed(key)
	pancake.keypressed(key)
end
