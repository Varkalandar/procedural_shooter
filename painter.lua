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


return painter
