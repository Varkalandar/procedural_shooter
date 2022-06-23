-- 
-- "Harmonic Shooter" enemy swarm
--
-- Author: Hj. Malthaner
-- Date: 2022/06/21
--

local bullets = require("bullets")
local swarm = {}


local function load(width, height)
	swarm.groups = {}  -- ship groups
	swarm.new = 0 -- highest group index
	swarm.old = 0 -- lowest group index
	swarm.width = width
	swarm.height = height
  swarm.tracer = bullets.makeNewTracer()
  swarm.tracer:load(width, height)
  
end


local function isObsolete(group)
  for k, v in pairs(group) do
    if v.x < -1000 or v.x > swarm.width + 1000 or
	     v.y < -1000 or v.y > swarm.height +1000 then
       return true
    end
  end
  
  return false
end


local function purgeObsoleteGroups()
  local group = swarm.groups[swarm.old]
	
  if group == nil then
    if swarm.old < swarm.new then
      print("Passing ship group #" .. swarm.old)
      swarm.old = swarm.old + 1
    end
	elseif isObsolete(group) then
    print("Purging ship group #" .. swarm.old)
    swarm.groups[swarm.old] = nil
    swarm.old = swarm.old + 1
	end
end


local function moveGroup(group)
  for k, v in pairs(group) do
    v.x = v.x + v.dx
    v.y = v.y + v.dy
  end
end


local function moveGroups()
  for i=swarm.old, swarm.new do
    local group = swarm.groups[i]
	
    if group then
      moveGroup(group)	
	  end
  end
end


local function fire(ships)
  for k, v in pairs(ships) do
    if v.hitpoints >= 0 then
      -- swarm.tracer:add(v.x-16, v.y + v.dy*2, -5, v.dy)
      swarm.tracer:add(v.x-16, v.y + v.dy*2, -5, 0)
    end
  end
end


local function update(dt)
  swarm.tracer:update(dt)
  
  purgeObsoleteGroups()
  moveGroups()

  for k, v in pairs(swarm.groups) do
    v[1].time = v[1].time + dt
    
    if v[1].time > 2.0 then
      fire(v)
      v[1].time = 0
    end
  end
  
end


local function drawGroup(group)

  -- print(dump(group))

  for k, v in pairs(group) do
  
    if v.hitpoints > 0 then
      love.graphics.setColor(1, 1, 1, 1)
      -- v.quad:setViewport(0, 0, 12*256, 256)
      v.quad:setViewport(0, 0, 128, 128)
      love.graphics.draw(v.canvas, v.quad, math.floor(v.x) - 64, math.floor(v.y) - 64)

      -- love.graphics.setColor(0, 0, 1, 1)
      -- love.graphics.rectangle('fill', math.floor(v.x) - 3, math.floor(v.y) - 3, 7, 7)
    else
      if v.hitpoints > -1 then
        v.sound:stop()
        v.sound:play()
      end
      
      if v.hitpoints > -20 then
      
        --[[
        -- fake explosion
        local size = 5 - v.hitpoints 
        
        love.graphics.setColor(1, 0.9, 0.5, 0.3)
        love.graphics.rectangle('fill', math.floor(v.x)-1, math.floor(v.y)-size, 3, size*2)
        love.graphics.rectangle('fill', math.floor(v.x)-size, math.floor(v.y)-1, size*2, 3)

        size = size * 0.5
        love.graphics.rectangle('fill', math.floor(v.x)-5, math.floor(v.y)-size, 11, size*2)
        love.graphics.rectangle('fill', math.floor(v.x)-size, math.floor(v.y)-5, size*2, 11)

        love.graphics.setColor(1, 1, 1, 0.3)
        size = size * 0.6
        love.graphics.rectangle('fill', math.floor(v.x)-size, math.floor(v.y)-size, size*2, size*2)
        size = size * 0.6
        love.graphics.rectangle('fill', math.floor(v.x)-size, math.floor(v.y)-size, size*2, size*2)
        ]]
        
        local mode, alphamode = love.graphics.getBlendMode();   
        love.graphics.setBlendMode("add")
        local frame = 1 + math.floor(v.hitpoints * -0.5)
        v.quad:setViewport(frame * 256, 0, 256, 256)
        love.graphics.draw(v.canvas, v.quad, math.floor(v.x) -128, math.floor(v.y) - 128)
        love.graphics.setBlendMode(mode, alphamode)

        -- use negative hitpoints as animation counter
        v.hitpoints = v.hitpoints - 1
      end
    end
  end
end


local function draw()
  for i=swarm.old, swarm.new do
    local group = swarm.groups[i]	
    if group then
      drawGroup(group)	
	  end
  end

  swarm.tracer:draw()
end


local function addShips(ships)
	print("Adding ships in slot=" .. swarm.new)
    
    -- print(dump(ships))
    
  ships[1].time = 0
	swarm.groups[swarm.new] = ships
	swarm.new = swarm.new + 1
end


swarm.load = load
swarm.update = update
swarm.draw = draw

swarm.addShips = addShips

return swarm
