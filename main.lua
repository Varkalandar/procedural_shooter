-- 
-- "Harmonic Shooter" startup file
--
-- Author: Hj. Malthaner
-- Date: 2022/06/14
--

-- global functions
require("painter")

local stars = require("stars")
local tunnel = require("levels/tunnel")
local platform = require("levels/platform")
local shipyard = require("shipyard")
local swarm = require("swarm")
local player = require("player")


-- global game time
time = 0 

local width = 1000
local height = 600
local state = 0
local anyKey = false

-- music thread
local music = {}
  
  
-- start a new game
local function newGame()
  anyKey = false
  state = 1

  stars.load(width, height)
  levelBg.load(width, height)
  swarm.load(width, height, player)
  shipyard.load()
  player.load(width, height, swarm, levelBg)

  -- roll in the levelBg
  stars.update(50)  
  levelBg.update(50)  
end


-- all init code goes here
function love.load()
  
  local ok = love.window.setMode(width, height, 
                                 {vsync=1, resizable=false})

  if not ok then 
    print("Window setup failed")
  end
  
  love.window.setTitle("Harmonic Shooter Alpha v0.08")
  
  player.load(width, height, swarm)
  local id = player.canvas:newImageData(0, 1, 32, 32, 64, 64)
  love.window.setIcon(id)

  platform.load(width, height)
  
  levelBg = tunnel
  newGame()
  state = 0
  
  music.channel = love.thread.getChannel("control")
  music.thread = love.thread.newThread("music.lua")
  music.thread:start()
end


local function updateGame(dt)
  time = time + dt 
  stars.update(dt)
  levelBg.update(dt)
  shipyard.update(dt)
  swarm.update(dt)
  player.update(dt)
  
  if love.math.random() < 0.01 and
     shipyard.needsSound == false and
     shipyard.needsExplosion == false then
    local count = math.floor(1 + love.math.random() * 8) 
    local ships = shipyard.makeShips(count)
    swarm.addShips(ships)
  end

  if player.power < 0 then
    -- game over
    state = 2
    anyKey = false
  end  
end


-- the work that has to be done before each frame can be drawn
-- dt is a float, measuring in seconds
function love.update(dt)
  if state == 0 then
    stars.update(dt*0.5)
    levelBg.update(dt*0.5)
    if anyKey then
      newGame()
    end
  elseif state == 1 then
    updateGame(dt)
  elseif state == 2 then
    if anyKey then
      newGame()
    end
  end
  
  if love.keyboard.isDown("f8") then    
    love.graphics.captureScreenshot("screenshot.png")
    print("Screenshot saved.")
  end
end


local function drawTitle()
  stars.draw()
  levelBg.draw()
  
  love.graphics.setColor(1, 0.5, 0, 1)
  love.graphics.setFont(fonts.giant)
  love.graphics.print("The Harmonic", 50, 100)
  love.graphics.print("Shooter", 240, 250)

  love.graphics.setColor(0.5, 1, 0, 1)
  love.graphics.setFont(fonts.normal)
  -- love.graphics.print("Press any key to start", 400, 420)
  love.graphics.print("Press 1 to enter the asteroid tunnel", 360, 416)
  love.graphics.print("Press 2 to raid the space platform", 360, 444)
end


local function drawGame()
  stars.draw()
  levelBg.draw()
  swarm.draw()
  player.draw()
end


local function drawGameOver()
  stars.draw()
  levelBg.draw()
  swarm.draw()
  player.draw()
  
  love.graphics.setColor(0.0, 0.05, 0.1, 0.4)
  love.graphics.rectangle('fill', 0, 0, width, height)

  love.graphics.setColor(1, 0.5, 0, 1)
  love.graphics.setFont(fonts.giant)
  love.graphics.print("Game Over", 110, 180)

  love.graphics.setColor(0.5, 1, 0, 1)
  love.graphics.setFont(fonts.normal)
  love.graphics.print("Press any key to start again", 370, 370)
end


-- draw the frame
function love.draw()
  love.graphics.setBlendMode("alpha")
  if state == 0 then
    drawTitle()
  elseif state == 1 then
    drawGame()
  elseif state == 2 then
    drawGameOver()
  end
end


-- for the "wait for any key"
-- except for game wide hotkeys
function love.keypressed(key, scancode, isrepeat)
  if key == "m" then
    music.channel:push("togglePause")
  elseif key == "1" then
    levelBg = tunnel
    anyKey = true
  elseif key == "2" then
    levelBg = platform
    anyKey = true
  else
    anyKey = true
  end
end


function love.quit()
  music.channel:push("stop")
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
