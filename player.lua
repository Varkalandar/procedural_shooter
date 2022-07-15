-- 
-- "Harmonic Shooter" player file
--
-- Author: Hj. Malthaner
-- Date: 2022/06/22
--

local player = {}
local bullets = require("bullets")
local sounds = require("sounds")


local function makeShip()
  love.graphics.setCanvas(player.canvas)
  love.graphics.clear()
  love.graphics.setBlendMode("alpha")
  local xoff = 64
  local yoff = 64

  -- shield effect
  love.graphics.setColor(0, 0, 1, 0.5)
  fillOval(xoff-2, yoff, 40)
  love.graphics.setBlendMode("subtract")
  love.graphics.setColor(0, 0, 0.25, 1)
  fillOval(xoff-2, yoff, 38)
  
  love.graphics.setBlendMode("alpha")
  for y=0, 15 do
    local dim = y / 30.0 + 0.3
    love.graphics.setColor(1*dim, 0.5*dim, 0*dim, 1)
  
    hline(xoff - 32 + y*2, yoff-15+y, y*2+1)
    hline(xoff - 32 + y*2, yoff+15-y, y*2-1)
  end
  
  love.graphics.setCanvas()

  player.gunsound = 
    sounds.make(180, -- duration
                sounds.pluckEnvelope, 
                128,
                -15,  -- shift
                2,  -- harmonics,
                0, -- vibrato,
                0, -- vibratoAmount,
                0.9, -- noise,
                24  -- noiseFrequencyDivision
                )
  player.gunsound:setVolume(0.025)

  player.gunhit = 
    sounds.make(240, -- duration
                sounds.pluckEnvelope, 
                128*0.5,
                -15,  -- shift
                2,  -- harmonics,
                150, -- vibrato,
                20, -- vibratoAmount,
                0.8, -- noise,
                -- 8  -- noiseFrequencyDivision
                18  -- noiseFrequencyDivision
                )
                
  player.gunhit:setVolume(0.08)

  player.tunnelcrash = 
    sounds.make(180, -- duration
                sounds.pluckEnvelope, 
                512,
                0,  -- shift
                2,  -- harmonics,
                0, -- vibrato,
                0, -- vibratoAmount,
                0.9, -- noise,
                4  -- noiseFrequencyDivision
                )
  player.tunnelcrash:setVolume(0.3)

  player.bonussound = 
    sounds.make(400, -- duration
                sounds.pluckEnvelope, 
                1024,
                50,  -- shift
                8,  -- harmonics,
                180, -- vibrato,
                100, -- vibratoAmount,
                0.1, -- noise,
                10  -- noiseFrequencyDivision
                )

end


local function makeBonusBall(x, y)
  love.graphics.setBlendMode("alpha")

  fillOval(x, y, 8)
  -- highlight
  love.graphics.setColor(1, 1, 1, 0.5)
  fillOval(x-2, y-2, 2)
  love.graphics.setColor(1, 1, 1, 0.75)
  fillOval(x-1, y-1, 1)
  love.graphics.setBlendMode("subtract")
  love.graphics.setColor(1, 1, 1, 0.5)
  fastOval(x+0.2, y+0.5, 7)
  
  love.graphics.setBlendMode("alpha")
end


local function makeBonusGfx()
  love.graphics.setCanvas(player.bonusCanvas)
  love.graphics.clear()
  love.graphics.setBlendMode("alpha")

  -- add max power bonus
  love.graphics.setColor(0.2, 0.3, 1, 0.9)
  makeBonusBall(8, 8)

  -- upper cannon bonus
  love.graphics.setColor(0.9, 0.3, 0, 0.9)
  makeBonusBall(16+8, 8)

  -- lower cannon bonus
  love.graphics.setColor(0.8, 0, 0.8, 0.9)
  makeBonusBall(32+8, 8)

  -- back cannon bonus
  love.graphics.setColor(0.3, 0.9, 0, 0.9)
  makeBonusBall(48+8, 8)

  -- bullet power bonus
  love.graphics.setColor(0.8, 0.7, 0, 0.9)
  makeBonusBall(64+8, 8)

  love.graphics.setCanvas()
end


local function drawPlayerBullet(bullet)
  if bullet.active then
    love.graphics.setColor(0.5*0.6, 1.0*0.6, 0.1*0.6, 1)
    love.graphics.rectangle('fill', math.floor(bullet.x)-2, math.floor(bullet.y)-1, 5, 3)
    love.graphics.setColor(0.5, 1, 0.1, 1)
    love.graphics.rectangle('fill', math.floor(bullet.x)-2, math.floor(bullet.y), 6, 1)
  end
end


local function drawBonus(bullet)
  if bullet.active then
    local mode, alphamode = love.graphics.getBlendMode();   
    love.graphics.setBlendMode("add")
    love.graphics.setColor(1, 1, 1, 1)
    
    player.bonusQuad:setViewport((bullet.data-1) * 16, 0, 16, 16)
    
    love.graphics.draw(player.bonusCanvas, player.bonusQuad, math.floor(bullet.x)-8, math.floor(bullet.y)-8)
    love.graphics.setBlendMode(mode, alphamode)
  end
end


local function load(width, height, swarm, tunnel)
  player.x = 100
  player.y = height/2
  player.dx = 0
  player.dy = 0
  player.widht = width
  player.height = height
  player.canvas = love.graphics.newCanvas(128, 128)
  player.bonusCanvas = love.graphics.newCanvas(16*5, 16)
  player.bonusQuad = love.graphics.newQuad(0, 0, 16, 16, player.bonusCanvas)
  player.timeBonusBase = 0
  player.time = 0
  player.power = 100
  player.maxPower = 200
  player.score = 0
  player.upperCannon = false
  player.lowerCannon = false
  player.backCannon = false
  player.bulletPower = 3
  player.tracer = bullets.makeNewTracer(drawPlayerBullet)
  player.tracer:load(width, height)
  player.bonuses = bullets.makeNewTracer(drawBonus)
  player.bonuses:load(width, height)
  player.swarm = swarm
  player.tunnel = tunnel
  
  -- show messages to the player
  player.message = ""
  player.messageTime = 0

  makeShip()
  makeBonusGfx()  
end


local function collectBonuses()
  local hit = player.bonuses:checkHits(player.x, player.y)
  
  if hit then
    if hit.data == 1 then
      player.maxPower = player.maxPower + 50    
      player.message = "+50 to max shield!"
    elseif hit.data == 2 then
      player.upperCannon = true
      player.message = "Upper cannon activated!"
    elseif hit.data == 3 then
      player.lowerCannon = true
      player.message = "Lower cannon activated!"
    elseif hit.data == 4 then
      player.backCannon = true
      player.message = "Back cannon activated!"
    elseif hit.data == 5 then
      player.bulletPower = player.bulletPower + 1
      player.message = "+1 to bullet power!"
    end

    -- show mesage for 3 seconds
    player.messageTime = time + 3
    
    player.bonussound:stop()
    player.bonussound:setPitch(1 + (math.random() - 0.5) * 0.25)
    player.bonussound:play()

  end  
end


local function makeBonus(v)
  local type = 1 + math.floor(love.math.random() * 5)
  -- local type = 5
  player.bonuses:add(v.x, v.y, -1, (love.math.random() - 0.5), type)
end


local function checkTunnelCollision()
  local tunnel = player.tunnel
  local left = math.floor(tunnel.right) - tunnel.width
  local px = math.floor(player.x)
  local x = (left + px) % (2*tunnel.width)
  
  local top = tunnel.topY[x] 
  local bottom = tunnel.bottomY[x] 

  -- vline(, top, bottom-top)

  if player.y < top + 32 or player.y > bottom-32 then
    player.power = player.power - 1
    player.tunnelcrash:stop()
    player.tunnelcrash:setPitch(1 + (math.random() - 0.5) * 0.25)
    player.tunnelcrash:play()
  end
end


local function checkHits()
  for i=player.swarm.old, player.swarm.new do
    local group = player.swarm.groups[i]	
    if group then
      for k, v in pairs(group) do
        if v.hitpoints > 0 then
          local hit = player.tracer:checkHits(v.x, v.y)
          if hit then
            -- print("Ship was hit")          
            local bulletPower = player.bulletPower * 200 / (time + 200)
            -- print("bullet power = " .. bulletPower)          
            v.hitpoints = math.max(0, v.hitpoints - bulletPower)
            
            -- draw a visual indicator for the hit
            v.flash = true
            if v.hitpoints > 0 then
              player.gunhit:stop()
              player.gunhit:setPitch((1 + (math.random() - 0.5) * 1) * 0.75)
              player.gunhit:play()
            else
              player.power = player.power + v.score
              player.score = player.score + v.score * 10
              
              -- chance for bonus
              if love.math.random() < player.timeBonusBase + v.score * 0.0018 then
                makeBonus(v)
                player.timeBonusBase = 0
              end
            end
          end
          
          -- ship collison checking
          local dx = v.x - player.x
          local dy = v.y - player.y
          local d = dx*dx + dy*dy
          
          if d < 2000 then
            player.power = player.power - 10
            player.gunhit:stop()
            player.gunhit:setPitch((1 + (math.random() - 0.5) * 1) * 0.5)
            player.gunhit:play()
          end          
        end
      end
    end
  end
end


local function fire()
  player.gunsound:stop()
  player.gunsound:play()

  player.tracer:add(player.x + 28, player.y, 5 + player.dx, 0 + player.dy)
  
  if player.upperCannon then
    player.tracer:add(player.x + 26, player.y-2, 5 + player.dx, -1.5 + player.dy)
  end
  
  if player.lowerCannon then
    player.tracer:add(player.x + 26, player.y+2, 5 + player.dx, 1.5 + player.dy)
  end
  
  if player.backCannon then
    player.tracer:add(player.x - 24, player.y, -5 + player.dx, 0 + player.dy)
  end
end


local function update(dt)
  player.tracer:update(dt)
  player.bonuses:update(dt)

  local speed = 180 * dt

  local vx = 0
  local vy = 0

  if love.keyboard.isDown("right") then  
    vx = 1
  elseif love.keyboard.isDown("left") then
    vx = -1
  end
  
  if love.keyboard.isDown("up") then
    vy = -1
  elseif love.keyboard.isDown("down") then
    vy = 1
  end

  player.x = player.x + vx*speed
  player.y = player.y + vy*speed
  player.dx = vx
  player.dy = vy
  player.time = player.time + dt
  player.timeBonusBase = player.timeBonusBase + dt * 0.0012
  
  player.x = math.max(64, (math.min(player.x, player.tracer.width - 64)))
  player.y = math.max(64, (math.min(player.y, player.tracer.height - 64)))
  
  if love.keyboard.isDown("lctrl") or
     love.keyboard.isDown("rctrl") then  
    if player.time > 0.1 then
      fire()
      player.time = 0
    end
  end

  -- player bullets
  checkHits()
  
  collectBonuses()
  
  checkTunnelCollision()  
  
  -- swarm bullets
  local hit = player.swarm.tracer:checkHits(player.x, player.y)
  if hit then
    player.power = player.power - math.floor(10 + time*0.1)
    player.tunnelcrash:stop()
    player.tunnelcrash:setPitch((1 + (math.random() - 0.5) * 1) * 0.5)
    player.tunnelcrash:play()    
  end

  if player.power > player.maxPower then
    player.power = player.maxPower
  end
end


local function drawShieldStatus(x, y)
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle('fill', x+81, y+1, 100, 16)
  love.graphics.setColor(0, 0, 1, 1)
  love.graphics.rectangle('fill', x+81, y+1, math.floor(100 * player.power / player.maxPower), 16)

  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("Shield:", x, y) 
  love.graphics.print(player.maxPower, x+200, y) 
  love.graphics.rectangle('line', x+80, y, 102, 18)
end


local function draw()
  player.tracer:draw()
  player.bonuses:draw()
  
  love.graphics.setColor(1, 1, 1, 1)
  local x = math.floor(player.x)
  local y = math.floor(player.y)
  love.graphics.draw(player.canvas, x - 64, y - 64)

  -- status
  drawShieldStatus(730, 10)

  love.graphics.setFont(fonts.big)
  love.graphics.print("Score: " .. player.score, 410, 10) 

  
  love.graphics.setFont(fonts.small)
  love.graphics.print("Bullet power: " .. player.bulletPower, 10, player.height-20)
  
  -- drive effect
  local drive = math.floor(time * 10) % 4
  love.graphics.setColor(0.8, 0.9, 1, 0.125)
  fastOval(x-26, y-4, 3+drive)
  fastOval(x-22, y, 5+drive)
  fastOval(x-26, y+4, 3+drive)
  -- core
  love.graphics.setColor(0.7, 0.85, 1, 0.25)
  love.graphics.ellipse("fill", x-30-drive, y, 7+drive*2, 2+drive, 24)
  
  -- messages
  if player.messageTime > time then
    love.graphics.setColor(0.2, 1, 0, 1)
    love.graphics.print(player.message, 400, 80)  
  end
end


player.load = load
player.update = update
player.draw = draw

return player
