-- 
-- "Harmonic Shooter" explosions file
--
-- Author: Hj. Malthaner
-- Date: 2022/06/21
--

local explosions = {}


local function makeStar(x, y, rad, color) 
  for i=0, rad do
    local dim = 4/(i+4)
    love.graphics.setColor(color.r*dim, color.g*dim, color.b*dim, color.a)

    setpix(x+i, y)
    setpix(x, y+i)
    setpix(x-i, y)
    setpix(x, y-i)
  end

  for i=1, rad/2 do
    local dim = 4/(i+4)
    love.graphics.setColor(color.r*dim, color.g*dim, color.b*dim, color.a)

    setpix(x+i, y+i)
    setpix(x+i, y-i)
    setpix(x-i, y+i)
    setpix(x-i, y-i)
  end
end


local function makeStarExplosion(hitpoints)
     
  local mode, alphamode = love.graphics.getBlendMode();   
     
  local x = {} 
  local y = {}
      
  local rad = 6
  local origins = 64
      
  for  i=0, origins-1 do
    local angle = love.math.random() * math.pi * 2
    local distance = love.math.random() * rad    
    x[i] = math.cos(angle) * distance
    y[i] = math.sin(angle) * distance
  end
  
  local colors = {}
      
  colors[0] = makeColor(0.3, 0.3)
  colors[1] = makeColorVariant(colors[0], 0.2)
  colors[2] = makeColorVariant(colors[0], 0.15)
  colors[3] = makeColorVariant(colors[0], 0.1)
      
  for i=0, 9 do
    -- ship canvas is ship (first frame) then 10 explosion frames
    local xoff = 256 + i * 256  
    
    -- set the area to black, "add" mode doesn't work with transparent
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle('fill', xoff, 0, 256, 256)
    love.graphics.setBlendMode("add")

    local distance = 4 + i*0.5 + hitpoints * 0.15
    local starshine = 0.1 + love.math.random() * 0.5
      
    -- 4 color shades
    for spot=0, origins-1, 4 do
      for color=0, 3 do
        local dx = math.floor(x[spot + color] * distance)
        local dy = math.floor(y[spot + color] * distance)
          
        local dim = 1 - i * 0.08
        local color = colors[color]
    
        makeStar(xoff + 128 + dx, 
                       128 + dy, 
                       2 + hitpoints * i * 0.08 + love.math.random()*3,
                       {r=color.r*dim, g=color.g*dim, b=color.g*dim, a=starshine})
                       
      end
    end
    
    for spot=0, origins-1, 4 do
      for color=0, 3 do
        local dx = math.floor(x[spot + color] * distance)
        local dy = math.floor(y[spot + color] * distance)
        local color = colors[color]    
        local cr = 12 + hitpoints * i * 0.1 + love.math.random()*5;
        local dim = 0.5
        
        love.graphics.setColor(color.r*dim, color.g*dim, color.b*dim, 0.1)

        fillOval(xoff+128 + dx, 128 + dy, cr)                    
        fillOval(xoff+128 + dx, 128 + dy, cr*0.5)                    
        fillOval(xoff+128 + dx, 128 + dy, cr*0.25)                    
      end
    end
  end

  love.graphics.setBlendMode(mode, alphamode)
end
    

explosions.makeStarExplosion = makeStarExplosion


return explosions
