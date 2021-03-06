-- 
-- "Harmonic Shooter" global drawing functions
--
-- Author: Hj. Malthaner
-- Date: 2022/06/21
--

local painter = {}


function setpix(x, y)
  love.graphics.rectangle('fill', x, y, 1, 1)
end


function hline(x, y, width)
  love.graphics.rectangle('fill', x, y, width, 1)
end


function vline(x, y, height)
  love.graphics.rectangle('fill', x, y, 1, height)
end


function fillOval(xc, yc, radius)
  local f = 1 - radius
  local ddF_x = 1
  local ddF_y = -2 * radius
  local x = 0
  local y = radius

  local lineMarks = {}
        
  hline(xc-radius, yc, radius+radius+1)
        
  while x < y do 
    if f >= 0 then
      y = y - 1
      ddF_y = ddF_y + 2
      f = f + ddF_y
    end
                
    x = x+1
    ddF_x = ddF_x +2
    f = f + ddF_x;

    if lineMarks[y] == nil then
        hline(xc-x, yc+y, x+x)
        hline(xc-x, yc-y, x+x)
        lineMarks[y] = true
    end
    
    if lineMarks[x] == nil then
        hline(xc-y, yc+x, y+y)
        hline(xc-y, yc-x, y+y)
        lineMarks[x] = true
    end
  end
end


function fastOval(x, y, radius)
  love.graphics.ellipse("fill", x, y, radius, radius, 24)
end


function makeStar(x, y, rad, color) 
  -- h/v spikes
  for i=0, rad do
    local dim = rad/(i*1.2+rad)
    love.graphics.setColor(color.r*dim, color.g*dim, color.b*dim, color.a*dim)

    setpix(x+i, y)
    setpix(x, y+i)
    setpix(x-i, y)
    setpix(x, y-i)
  end

  -- diagonal spikes
  for i=1, rad/2 do
    local dim = rad/(i*1.2+rad)
    love.graphics.setColor(color.r*dim, color.g*dim, color.b*dim, color.a*dim)

    setpix(x+i, y+i)
    setpix(x+i, y-i)
    setpix(x-i, y+i)
    setpix(x-i, y-i)
  end
end


function makeColor(base, range)
  return
  {
    r = base + love.math.random() * range,
    g = base + love.math.random() * range,
    b = base + love.math.random() * range,
    a = 1
  }
end


function makeColorVariant(color, var) 
  return
  {
    r = color.r + love.math.random() * var * 2 - var,
    g = color.g + love.math.random() * var * 2 - var,
    b = color.b + love.math.random() * var * 2 - var,
    a = color.a
  }
end

fonts = {}
fonts.small = love.graphics.newFont(14)
fonts.normal = love.graphics.newFont(18)
fonts.big = love.graphics.newFont(24)
fonts.giant = love.graphics.newFont(128)

return painter
