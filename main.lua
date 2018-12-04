function love.load()
	Bob = {}
	Bob.x = 0
	Bob.y = 0 
	Bob.speed = 200
	Bob.bullets = {}
	Bob.firing = false
	Bob.moving = false
	Bob.forward= true
	Bob.y_velocity = 0
	Bob.jump_height = -300
	Bob.gravity = -500
	Bob.jumping = false
	
	trt = 0
	
	calcSpriteNum = function(animation)
		spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
		return spriteNum
	end
	
	default_ani = newAnimation(love.graphics.newImage("Bob the Blob.png"), 16, 11, 1)
	moving_ani  = newAnimation(love.graphics.newImage("Bob the Blob_ Forward.png"), 16, 11, 0.5)
	pug_ani = newAnimation(love.graphics.newImage("PUG.png"), 240, 179, 1)
	gun_ani = newAnimation(love.graphics.newImage("Bob's gun.png"), 23, 9, 1)
	jump_ani = newAnimation(love.graphics.newImage("Bob the Blob_ jump.png"), 16, 11, 1)
	
	Bob.fire = function()
		bullet = {}
		bullet.x = Bob.x + 27
		bullet.y = Bob.y + 6
		table.insert(Bob.bullets, bullet)
	end
end

function love.update(dt)
	if love.keyboard.isDown("right") and Bob.x <= 765 then
		Bob.x = Bob.x + (Bob.speed * dt)
		Bob.forward = true
	end
	if love.keyboard.isDown("left") and Bob.x >= 0 then
		Bob.x = Bob.x - (Bob.speed * dt)
		Bob.forward = false
	end
	if not love.keyboard.isDown("left") and not love.keyboard.isDown("right") then
		Bob.moving = false
	else
		Bob.moving = true
	end
	
	if love.keyboard.isDown("j") then
		if Bob.y_velocity == 0 then
			Bob.y_velocity = Bob.jump_height
			Bob.jumping = true
		end
	end
	if Bob.y_velocity ~= 0 then
		Bob.y = Bob.y + Bob.y_velocity * dt
		Bob.y_velocity = Bob.y_velocity - Bob.gravity * dt
	end
	if Bob.y > 478 then
		Bob.y_velocity = 0
		Bob.y = 478
	end
	
	if not love.keyboard.isDown("space") then
		Bob.firing = false
	end
	if love.keyboard.isDown("space") and not Bob.firing then
		Bob.firing = true
		Bob.fire() 
	end
	
	trt = trt + (100 * dt)
	
	animationUpdate = function(animation)
		animation.currentTime = animation.currentTime + dt
		
		if animation.currentTime >= animation.duration then
			animation.currentTime = animation.currentTime - animation.duration
		end
	end
	
	jumpUpdate = function(animation)
		animation.currentTime = animation.currentTime + dt
		
		if animation.currentTime >= animation.duration then
			Bob.jumping = false
		end
	end
	
	jumpSprite = function(animation)
	end
	
	animationUpdate(default_ani)
	animationUpdate(moving_ani)
	animationUpdate(pug_ani)
	animationUpdate(gun_ani)
	jumpUpdate(jump_ani)
	
	for i,b in pairs(Bob.bullets) do
		b.x = b.x + 5
		if b.y < -10 or b.x > 810 then
			table.remove(Bob.bullets, i)
		end
	end
end

function love.draw()
	love.graphics.setBackgroundColor(120, 120, 240)
	love.graphics.setColor(255, 255, 255)
		
	if not Bob.moving and not Bob.jumping then
		if Bob.forward then
			love.graphics.draw(default_ani.spriteSheet, default_ani.quads[calcSpriteNum(default_ani)], Bob.x, Bob.y, 0, 2, 2)
			love.graphics.draw(gun_ani.spriteSheet, gun_ani.quads[calcSpriteNum(gun_ani)], Bob.x - 2, Bob.y + 4, 0, 2, 2)
		else
			love.graphics.draw(default_ani.spriteSheet, default_ani.quads[calcSpriteNum(default_ani)], Bob.x + 32, Bob.y, 0, -2, 2)
			love.graphics.draw(gun_ani.spriteSheet, gun_ani.quads[calcSpriteNum(gun_ani)], Bob.x - 2 + 32, Bob.y + 4, 0, -2, 2)
		end
	elseif Bob.jumping then
		love.graphics.draw(jump_ani.spriteSheet, jump_ani.quads[calcSpriteNum(jump_ani)], Bob.x, Bob.y, 0, 2, 2)
	else
		if Bob.forward then
			love.graphics.draw(moving_ani.spriteSheet, moving_ani.quads[calcSpriteNum(moving_ani)], Bob.x, Bob.y, 0, 2, 2)
			love.graphics.draw(gun_ani.spriteSheet, gun_ani.quads[calcSpriteNum(gun_ani)], Bob.x - 2, Bob.y + 4, 0, 2, 2)
		else
			love.graphics.draw(moving_ani.spriteSheet, moving_ani.quads[calcSpriteNum(moving_ani)], Bob.x + 32, Bob.y, 0, -2, 2)
			love.graphics.draw(gun_ani.spriteSheet, gun_ani.quads[calcSpriteNum(gun_ani)], Bob.x - 2 + 34, Bob.y + 4, 0, -2, 2)
		end
	end
	
	if trt < 800 then
		love.graphics.draw(pug_ani.spriteSheet, pug_ani.quads[calcSpriteNum(pug_ani)], 800 - trt, 500 - 36, 0, -0.2, 0.2)
	end
	
	love.graphics.setColor(75, 0, 130)
	for _,v in pairs(Bob.bullets) do
		love.graphics.rectangle("fill", v.x, v.y, 10, 10)
	end
	
	love.graphics.setColor(0, 255, 0)
	love.graphics.rectangle("fill", 0, 500, 800, 100)
	love.graphics.rectangle("fill", 0, 50, 100, 100)
end

function newAnimation(image, width, height, duration)
	local animation = {}
	animation.spriteSheet = image;
	animation.quads = {};
	animation.duration = duration or 1
	animation.currentTime = 0
	
	for y=0, image:getHeight() - height, height do
		for x=0, image:getWidth() - width, width do
			table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
		end
	end
	return animation
end
