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
end


local function load(width, height, swarm)
  player.x = 100
  player.y = height/2
  player.canvas = love.graphics.newCanvas(128, 128)
  player.time = 0
  player.tracer = bullets.makeNewTracer()
  player.tracer:load(width, height)
  player.tracer.color.r = 0.5
  player.tracer.color.g = 1.0
  player.tracer.color.b = 0.1
  player.swarm = swarm
  makeShip()  
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
            local bulletPower = 3
            v.hitpoints = math.max(0, v.hitpoints - bulletPower)
            
            -- draw a visual indicator for the hit
            v.flash = true
          end
        end
      end
    end
  end
end


local function fire()
  player.gunsound:stop()
  player.gunsound:play()

  player.tracer:add(player.x + 28, player.y, 5, 0)
end


local function update(dt)
  player.tracer:update(dt)

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
  player.time = player.time + dt
  
  if love.keyboard.isDown("lctrl") or
     love.keyboard.isDown("rctrl") then  
    if player.time > 0.1 then
      fire()
      player.time = 0
    end
  end

  checkHits()
end


local function draw()
  player.tracer:draw()
  
  love.graphics.setColor(1, 1, 1, 1)
  local x = math.floor(player.x)
  local y = math.floor(player.y)
  love.graphics.draw(player.canvas, x - 64, y - 64)
  
  -- drive effect
  local drive = math.floor(time * 10) % 4
  love.graphics.setColor(0.8, 0.9, 1, 0.125)
  fastOval(x-26, y-4, 3+drive)
  fastOval(x-22, y, 5+drive)
  fastOval(x-26, y+4, 3+drive)
  -- core
  -- love.graphics.setColor(0.7, 0.85, 1, 0.25)
  -- fastOval(x-20, y, 5)
  -- fastOval(x-18, y, 3)
end


player.load = load
player.update = update
player.draw = draw

return player
