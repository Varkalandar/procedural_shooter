-- 
-- "Harmonic Shooter" explosions file
--
-- Author: Hj. Malthaner
-- Date: 2022/06/21
--

local explosions = {}


-- reuse these to avoid creating too much garbage
local x = {} 
local y = {}
local colors = {}

-- temporary color, created only once to reduce garbage
local tc = {r=0, g=0, b=0, a=1}

local function makeStarExplosion(hitpoints)
  -- sanity limits, we can only explode to canvas size limits
  hitpoints = math.min(16, hitpoints)
  
  local mode, alphamode = love.graphics.getBlendMode();   
      
  local rad = 3 + hitpoints * 0.2
  local origins = 24 + math.floor(0.75 * hitpoints) * 4
  local compact = 0.1 + math.random() * 0.1 
  
  -- print("origins=" .. origins)
  
  for  i=0, origins-1 do
    local angle = love.math.random() * math.pi * 2
    local distance = 0.3 + love.math.random() * rad    
    x[i] = math.cos(angle) * distance
    y[i] = math.sin(angle) * distance
  end
  
  colors[0] = makeColor(0.3, 0.3)
  colors[1] = makeColorVariant(colors[0], 0.35)
  colors[2] = makeColorVariant(colors[0], 0.25)
  colors[3] = makeColorVariant(colors[0], 0.15)
  
  for i=0, 9 do
    -- ship canvas is ship (first frame) then 10 explosion frames
    local xoff = 256 + i * 256 + 128 
    
    -- set the area to black, "add" mode doesn't work with transparent
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle('fill', xoff, 0, 256, 256)
    love.graphics.setBlendMode("add")

    local distance = 1 + i*1.5 + hitpoints * 0.15
    local starshine = 0.3 + love.math.random() * 0.7
    tc.a = starshine
    local dim = 1 - i * 0.1
      
    -- 4 color shades
    for spot=0, origins-1, 4 do
      for color=0, 3 do
        local dx = math.floor(x[spot + color] * distance*1.5)
        local dy = math.floor(y[spot + color] * distance*1.5)
          
        local color = colors[color]
        tc.r = color.r*dim
        tc.g = color.g*dim
        tc.b = color.g*dim
        
        local size = math.floor(1 + hitpoints * i * compact + love.math.random()*4)
        
        makeStar(xoff + dx, 
                       128 + dy, 
                       math.min(size, 4),
                       tc)
      end
    end
    
    for spot=0, origins-1, 4 do
      for color=0, 3 do
        local dx = math.floor(x[spot + color] * distance)
        local dy = math.floor(y[spot + color] * distance)
        local color = colors[color]    
        local cr = 10 + hitpoints * i * compact*1.5 + love.math.random()*10
        
        love.graphics.setColor(color.r*dim, color.g*dim, color.b*dim, 0.08)

        fastOval(xoff + dx, 128 + dy, cr)                    
        fastOval(xoff + dx, 128 + dy, cr*0.8)                    
        fastOval(xoff + dx, 128 + dy, cr*0.6)                    
        fastOval(xoff + dx, 128 + dy, cr*0.4)                    
      end
    end
    
  end
  
  love.graphics.setBlendMode(mode, alphamode)
end
    

explosions.makeStarExplosion = makeStarExplosion


return explosions
