-- 
-- "Harmonic Shooter" shipyard, makes ships
--
-- Author: Hj. Malthaner
-- Date: 2022/06/21
--

local explosions = require("explosions")
local sounds = require("sounds")

local shipyard = {}


local function makeShipGfx(canvas)
  love.graphics.setCanvas(canvas)
  love.graphics.clear()
  love.graphics.setBlendMode("alpha")
  love.graphics.setColor(1, 0, 0, 1)
  love.graphics.rectangle('fill', 128-20, 128-20, 40, 40)
  love.graphics.setCanvas()
end


local function makeDendrilEnemy(canvas)
  local width = 16 + (love.math.random()*48)
  local height = 16 + (love.math.random()*48)
        
  local hitpoints = 1

  local xp = 64
  local yp = 64
  local compact = 0.5 + love.math.random() * 0.8
        
  love.graphics.setCanvas(canvas)
  love.graphics.clear()
  love.graphics.setBlendMode("alpha")

  local color = 
  {
    r = love.math.random() * 0.5 + 0.4,
    g = love.math.random() * 0.5 + 0.4,
    b = love.math.random() * 0.5 + 0.4,
  }

  repeat

    love.graphics.setColor(color.r, color.g, color.b, 1)
    
    color.r = color.r + math.random() * 0.01 - 0.005
    color.g = color.g + math.random() * 0.01 - 0.005 
    color.b = color.b + math.random() * 0.01 - 0.005 
    
    love.graphics.rectangle('fill', math.floor(xp), math.floor(yp), 1, 1);
    love.graphics.rectangle('fill', math.floor(xp), math.floor(128-yp), 1, 1);

    -- love.graphics.rectangle('fill', math.floor(wh - xp*0.5), math.floor(hh + yp*0.5), 1, 1);
    -- love.graphics.rectangle('fill', math.floor(wh - xp*0.5), math.floor(hh - yp*0.5), 1, 1);

    if love.math.random() < 0.002 then
      -- big highlights
      love.graphics.setColor(color.r*1.4, color.g*1.4, color.b*1.4, 0.7)
      love.graphics.rectangle('fill', math.floor(xp-2), math.floor(yp-2), 5, 5);
      love.graphics.rectangle('fill', math.floor(xp-2), math.floor(128-yp-2), 5, 5);
    elseif love.math.random() < 0.006 then
      -- highlights
      love.graphics.setColor(color.r*1.4, color.g*1.4, color.b*1.4, 1)
      love.graphics.rectangle('fill', math.floor(xp), math.floor(yp), 1, 1);
      love.graphics.rectangle('fill', math.floor(xp), math.floor(128-yp), 1, 1);
    elseif love.math.random() < 0.2 then
      -- shadows
      love.graphics.setColor(0, 0, 0, 0.1)
      love.graphics.rectangle('fill', math.floor(xp-1), math.floor(yp-1), 3, 3);
      love.graphics.rectangle('fill', math.floor(xp-1), math.floor(128-yp-1), 3, 3);
    elseif love.math.random() < 0.05 then
      -- double shadows
      love.graphics.setColor(0, 0, 0, 0.8)
      love.graphics.setColor(color.r*0.5, color.g*0.5, color.b*0.5, 0.5)
      love.graphics.rectangle('fill', math.floor(xp), math.floor(yp), 1, 1);
      love.graphics.rectangle('fill', math.floor(xp), math.floor(128-yp), 1, 1);
    end
    
    xp = xp + (love.math.random() - 0.5) * compact
    yp = yp + (love.math.random() - 0.5) * compact * 0.5
    
    -- print("xp=" .. xp .. " yp=" .. yp)
      
    hitpoints = hitpoints + 1
  until xp < 1 or yp < 1 or xp > 126 or yp > 126 or hitpoints > 4000

  -- love.graphics.setColor(1, 0, 0, 1)
  -- love.graphics.rectangle('line', 0, 0, 128, 128)
  
  love.graphics.setCanvas()
end


local function makeWingedEnemy(canvas)
  local width = 16 + math.floor(love.math.random() * 40)
  local height = 16 + math.floor(love.math.random() * 40)
        
  local xoff = (128 - width) / 2
  local yoff = (128 - height) / 2
        
  local hitpoints = 1

  local left = math.floor(love.math.random() * width/2)
  local right = left + 8 + math.floor(love.math.random() * (width - left - 9))
        
  local seamSpace = 4 + math.floor(love.math.random() * 5)     
  local seamDark = 0.1 + love.math.random() * 0.4
       
  local gunLength = 3 + math.floor(love.math.random() * 5)     
       
  local color = 
  {
    r = love.math.random() * 0.4 + 0.25,
    g = love.math.random() * 0.4 + 0.25,
    b = love.math.random() * 0.4 + 0.25,
  }
 
  love.graphics.setCanvas(canvas)
  love.graphics.clear()
  love.graphics.setBlendMode("alpha")
        
  for y=0, height/2-1 do
    local dim = (y / height) + 0.5
    
    -- print("y=" .. y .. " dim=" .. dim)
    
    local top = yoff + y
    local bot = yoff + height-y-2
    
    love.graphics.setColor(color.r*0.8*dim, color.g*0.8*dim, color.b*0.8*dim, 1)
            
    hline(xoff + left-1, top, right - left + 3)
    hline(xoff + left-1, bot, right - left + 3)
            
    love.graphics.setColor(color.r*1.2*dim, color.g*1.2*dim, color.b*1.2*dim, 1)
            
    hline(xoff + left+1, top, right - left - 1)
    hline(xoff + left+1, bot, right - left - 1)

    -- dot over dark weld seams
    love.graphics.setColor(0, 0, 0, seamDark)
    for x=left-1, right+3, seamSpace do
      hline(xoff + x, top, 1)
      hline(xoff + x, bot, 1)
    end


    -- decorations
    if love.math.random() < 0.3 and left + 8 <= right then
      local wid = 4 + math.floor(love.math.random() * 3)
      love.graphics.setColor(color.r*2*dim, color.g*2*dim, color.b*2*dim, 1)

      if love.math.random() < 0.5 then
        wid = right - left - 2;
        love.graphics.setColor(color.r*1.0*dim, color.g*1.0*dim, color.b*1.0*dim, 1)
      end          
      
      hline(xoff + left+3, top, wid)
      hline(xoff + left+3, bot, wid)
    end            

    -- gun spikes
    if love.math.random() < 0.1 then
      love.graphics.setColor(color.b*1.0*dim, color.g*1.0*dim, color.r*1.0*dim, 1)
      hline(xoff + left-gunLength, top-1, gunLength+1)
      hline(xoff + left-gunLength, top+1, gunLength+1)
      hline(xoff + left-gunLength, bot-1, gunLength+1)
      hline(xoff + left-gunLength, bot+1, gunLength+1)
      love.graphics.setColor(color.b*1.2*dim, color.g*1.2*dim, color.r*1.2*dim, 1)
      hline(xoff + left-gunLength-1, top, gunLength+2)
      hline(xoff + left-gunLength-1, bot, gunLength+2)
    end
    
    hitpoints = hitpoints + right - left
            
    left = left + math.floor(love.math.random() * 8 - 5)
    right = right + math.floor(love.math.random() * 8 - 3)
            
    left = math.min(math.max(0, left), width-1)
    right = math.min(math.max(1, right), width-1)

    if left + 4 >= right then
      left = left - 2
      right = right + 2
    end
    
    -- color drift
    color.r = color.r + math.random() * 0.1 - 0.05
    color.g = color.g + math.random() * 0.1 - 0.05 
    color.b = color.b + math.random() * 0.1 - 0.05     
  end

  -- love.graphics.setColor(0, 1, 0, 1)
  -- love.graphics.rectangle('line', 0, 0, 128, 128)

  love.graphics.setCanvas()
end


local function makeShellEnemy(canvas)
  local baseRadius = 35;

  local hitpoints = 1;

  local colorCenter = {}
  local colorBorder = {}

  colorCenter.r = 0.25 + love.math.random() * 0.5
  colorCenter.g = 0.25 + love.math.random() * 0.5
  colorCenter.b = 0.25 + love.math.random() * 0.5

  colorBorder.r = colorCenter.r + 0.25 - love.math.random() * 0.5
  colorBorder.g = colorCenter.g + 0.25 - love.math.random() * 0.5
  colorBorder.b = colorCenter.b + 0.25 - love.math.random() * 0.5

  local radius = baseRadius * 0.9;
  local shellShape = 0.3 + love.math.random() * 0.2;
  local tussleFactor = 3.0 + love.math.random() * 10.0;
  local ripples = 3 + math.floor(love.math.random() * 9)

  -- flat ship center
  local center = 0.2 + love.math.random() * 0.2;

  local minX = 100
  local minY = 100
  local maxX = 0
  local maxY = 0

  love.graphics.setCanvas(canvas)
  love.graphics.clear()
  love.graphics.setBlendMode("alpha")
        
  for angle=0, math.pi, 0.02 do
    local xv = math.cos(angle)
    local yv = math.sin(angle)
            
    -- occasional bright lines on shell
    local brightLine = love.math.random() < 0.1
            
    for r=0, radius-1 do
      local xpos = math.floor(xv * r)
      local ypos = math.floor(yv * r)
                
      local R = colorBorder.r
      local G = colorBorder.g
      local B = colorBorder.b
                
      local dark = radius / baseRadius
      dark = dark * dark
                
      R = (R * dark)
      G = (G * dark)
      B = (B * dark)
                
      R = (colorCenter.r + ((R - colorCenter.r) * r / radius))
      G = (colorCenter.g + ((G - colorCenter.g) * r / radius))
      B = (colorCenter.b + ((B - colorCenter.b) * r / radius))

      local ripple = 0.75 + math.sin(r / radius * math.pi * ripples) * 0.25;
                
      R = (R * ripple)
      G = (G * ripple)
      B = (B * ripple)
      
      if r < radius * center then
        R = (colorCenter.r + ((R - colorCenter.r) * (1-center)));
        G = (colorCenter.g + ((G - colorCenter.g) * (1-center)));
        B = (colorCenter.b + ((B - colorCenter.b) * (1-center)));
      end

      if brightLine then
        R = colorCenter.r + 0.125
        G = colorCenter.g + 0.125
        B = colorCenter.b + 0.125
      end

      love.graphics.setColor(R, G, B, 1)
                
      hline(64+xpos, 64+ypos, 1)
      hline(64+xpos, 64-ypos, 1)

      -- if xpos < minX then minX=xpos end
      -- if xpos > maxX then maxX=xpos end
      -- if math.floor(baseRadius) - ypos < minY then minY = math.floor(baseRadius) - ypos end
      -- if math.floor(baseRadius) + ypos > maxY then maxY = math.floor(baseRadius) + ypos end
                
    end
    
    radius = radius + (love.math.random() - 0.5) * tussleFactor;

    if radius < baseRadius * 0.2 then
      radius = baseRadius * 0.2;
    end

    if radius > baseRadius * 0.96 then
      radius = baseRadius * 0.96;
    end

    radius = radius - shellShape
    
    hitpoints = hitpoints + radius;

    -- color drift
    colorCenter.r = colorCenter.r + math.random() * 0.1 - 0.05
    colorCenter.g = colorCenter.g + math.random() * 0.1 - 0.05 
    colorCenter.b = colorCenter.b + math.random() * 0.1 - 0.05     
  end

  -- love.graphics.setColor(0, 0, 1, 1)
  -- love.graphics.rectangle('line', 0, 0, 128, 128)

  love.graphics.setCanvas()
end


local function makeNewShipType()

  print("Making ship #" .. shipyard.next+1)
  
  local canvas = shipyard.canvases[(shipyard.next + 1) % 64]
  local r = love.math.random()
  local hitpoints = 1 + math.floor(love.math.random() * 7) -- todo!
  
  if r < 0.33 then
    makeShellEnemy(canvas)
  elseif r < 0.66 then
    makeWingedEnemy(canvas)
  else
    makeDendrilEnemy(canvas)
  end

  love.graphics.setCanvas(canvas)
  explosions.makeStarExplosion(hitpoints)
  love.graphics.setCanvas()
  
  -- advance to next shape
  shipyard.next = shipyard.next +1
  
  return hitpoints
end


local function makeExplosionSound(hitpoints)
  local frequency = 128
        
  if hitpoints == 1 then
    frequency = frequency * 2
  elseif hitpoints == 2 then
    frequency = frequency * 5 / 3
  elseif hitpoints == 3 then
    frequency = frequency * 3 / 2
  elseif hitpoints == 4 then
    frequency = frequency * 4 / 3
  elseif hitpoints == 5 then
    frequency = frequency * 4 / 3
  elseif hitpoints == 6 then
    frequency = frequency * 5 / 4
  elseif hitpoints == 7 then
    frequency = frequency * 9 / 8
  else
    frequency = frequency * 1
  end

  local sound
  
  if love.math.random() < 0.6 then
    local harmonics = 2 + math.floor(love.math.random()*2);
    local viba = 50 + math.floor(love.math.random()*30);
    local noise = 0.50 + love.math.random()*0.30
    local nfd = 24 + math.floor(love.math.random()*20);

    sound = sounds.make(500 + hitpoints*16, -- duration
                                    sounds.pluckEnvelope, -- new PluckWave(0.6),
                                    frequency,
                                    0, -- shift
                                    harmonics, -- harmonics,
                                    77, -- vibrato,
                                    viba, -- vibratoAmount,
                                    noise, -- noise,
                                    nfd  -- noiseFrequencyDivision
                                    )
  else
    local harmonics = 2 + math.floor(love.math.random()*2);
    local vibrato = 3 + math.floor(love.math.random()*2);
    local viba = 70 + math.floor(love.math.random()*20);
    local noise = 0.4 + love.math.random()*0.25
     -- int nfd = 4 + math.floor(love.math.random()*4);
    local nfd = 24 + math.floor(love.math.random()*20);

    sound = sounds.make(400 + hitpoints*16, -- duration
                                   -- new EarlyWave(0.45),
                                    sounds.pluckEnvelope, -- new PluckWave(0.8),
                                    frequency,
                                    0, -- shift
                                    harmonics, -- harmonics,
                                    vibrato,
                                    viba, -- vibratoAmount,
                                    noise, -- noise,
                                    nfd  -- noiseFrequencyDivision
                                    )
  end
  
  sound:setVolume(0.5)
  
  return sound
end


local function load(width, height)
  shipyard.canvases = {}
  shipyard.quads = {}
  
  for i=0,63 do	
    print("Making ship #" .. i+1)

    -- ship canvas is ship (first frame) then 10 explosion frames
    local canvas = love.graphics.newCanvas(12*256, 256)
    shipyard.canvases[i] = canvas
    quad = love.graphics.newQuad(0, 0, 128, 128, canvas)
    shipyard.quads[i] = quad    
  end

  shipyard.next = -1
  makeNewShipType()
end


local function update(dt)
end


local function makeShips(count)

  -- we keep one of these ahead,
  -- cause canvas takes a while to be ready?  
  local hitpoints = makeNewShipType() 
  
  local sound = makeExplosionSound(hitpoints)
  
  
  -- default, move from bottom to top
  local ystart = 600 + 128
  local xstart = 900 + love.math.random() * 200
  local xspace = love.math.random() * 120 - 60
  local yspace = 50
  local dx = love.math.random() * 4 - 3.7
  local dy = -1 - love.math.random()
  
  -- adjust 50% to move top to bottom
  if  love.math.random() < 0.5 then
    ystart = -128
    yspace = -50
    dy = 1 + love.math.random()
  end
  
  local ships = {}
  
  for i=1,count do
    local ship = {}
    -- ship center
    ship.x = xstart
    ship.y = ystart
    -- ship direction
    ship.dx = dx
    ship.dy = dy
    ship.canvas = shipyard.canvases[shipyard.next % 64]
    ship.quad = shipyard.quads[shipyard.next % 64]
    ship.hitpoints = hitpoints
    ship.sound = sound
    
    ships[i] = ship
    
    xstart = xstart + xspace
    ystart = ystart + yspace
  end
  
  return ships
end


shipyard.load = load
shipyard.update = update
shipyard.makeShips = makeShips

return shipyard
