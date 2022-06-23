-- 
-- "Harmonic Shooter" startup file
--
-- Author: Hj. Malthaner
-- Date: 2022/06/14
--

-- global functions
require("painter")

local tunnel = require("tunnel")
local shipyard = require("shipyard")
local swarm = require("swarm")
local player = require("player")


-- global game time
time = 0 

local width = 1000
local height = 600


-- all init code goes here
function love.load()
  
  local ok = love.window.setMode(width, height, 
                                                {vsync=1, resizable=false} )
  
  if not ok then 
    print("Window setup failed")
  end
  
  tunnel.load(width, height)
  swarm.load(width, height, player)
  player.load(width, height, swarm)
  shipyard.load()
  
  -- roll in the tunnel
  tunnel.update(100)
end


-- the work that has to be done before each frame can be drawn
-- dt is a float, measuring in seconds
function love.update(dt)
  time = time + dt 
  tunnel.update(dt)
  shipyard.update(dt)
  swarm.update(dt)
  player.update(dt)
  
  if love.math.random() < 0.01 then
    local count = math.floor(1 + love.math.random() * 8) 
    local ships = shipyard.makeShips(count)
    swarm.addShips(ships)
  end

  if love.keyboard.isDown("f8") then    
    love.graphics.captureScreenshot("screenshot.png")
    print("Screenshot saved.")
  end
end


-- draw the frame
function love.draw()
  tunnel.draw()
  swarm.draw()
  player.draw()
end


-- debug helper
function dump(o)
  if type(o) == 'table' then
    local s = '{ '
    for k,v in pairs(o) do
      if type(k) ~= 'number' then k = '"'..k..'"' end
      s = s .. '['..k..'] = ' .. dump(v) .. ','
    end
    return s .. '} '
  else
    return tostring(o)
  end
end

