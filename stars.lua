-- 
-- "Harmonic Shooter" star background file
--
-- Author: Hj. Malthaner
-- Date: 2022/07/05
--

local stars = {}


local function load(width, height)

  stars.width = width
  stars.height = height
  stars.topY = {}
  stars.bottomY = {}
  
  -- works as wraparound ring buffer
  stars.canvas = love.graphics.newCanvas(width*2, height)

  -- the visible area of the stars
  stars.quad = love.graphics.newQuad(0, 0, width, height, 
                                      stars.canvas)

  -- scroll speed, pixels per second
  stars.speed = 30
  stars.right = width - 1
  
  love.graphics.setCanvas(canvas)
  love.graphics.clear()
  love.graphics.setBlendMode("alpha")
  love.graphics.setColor(0, 0, 1, 1)
  love.graphics.rectangle('fill', 0, 0, width, height)
  love.graphics.setCanvas()  
end


local function update(dt)
  local r1 = math.floor(stars.right)
  local vd =  dt * stars.speed
  stars.right = stars.right + vd

  local r2 = math.floor(stars.right)

  love.graphics.setCanvas(stars.canvas)    
  love.graphics.setBlendMode("alpha")

  for x=r1, r2-1 do
    local xm = x % (2*stars.width)
    
    -- draw stars
    for y = 0, stars.height-1 do
      if love.math.random() < 0.002 then
        local lum = love.math.random() * 0.5 + 0.1

        -- dominant red or dominant blue star?
        if love.math.random() < 0.8 then
          local r = lum
          local g = r * (0.7 + love.math.random() * 0.3)
          local b = g * (0.7 + love.math.random() * 0.3)
          love.graphics.setColor(r, g, b, 1)
        else
          local b = lum
          local g = b * (0.7 + love.math.random() * 0.3)
          local r = g * (0.7 + love.math.random() * 0.3)
          love.graphics.setColor(r, g, b, 1)
        end
        
        if love.math.random() < 0.7 then
          -- small star
          vline(xm, y, 1)
        else
          -- big star  
          vline(xm, y, 2)
          vline(xm+1, y, 2)
        end
      end
      if love.math.random() < 0.0001 then
        
        if x < 3*stars.width - 5 then
          -- very big stars
          local lum = love.math.random() * 0.7 + 0.3

          local color
          if love.math.random() < 0.8 then
            local r = lum
            local g = r * (0.8 + love.math.random() * 0.4)
            local b = g * (0.7 + love.math.random() * 0.3)
            color = {r=r, g=g, b=b, a=1}
          else
            local b = lum
            local g = b * (0.7 + love.math.random() * 0.3)
            local r = g * (0.7 + love.math.random() * 0.3)
            color = {r=r, g=g, b=b, a=1}
          end

          local rad = 1 + math.floor(love.math.random() * 5)
          makeStar(xm + rad, y, rad, color)
        end
      end
    end
    
    -- clear left of visible field
    love.graphics.setColor(0, 0, 0, 1)
    vline((x-stars.width) % (2*stars.width), 0, stars.height)
    
  end
  
  love.graphics.setCanvas()
  
  -- wrap
  if stars.right >= 3*stars.width then  
    stars.right = stars.right - 2*stars.width
  end  
end


local function draw()
  love.graphics.setColor(1, 1, 1, 1)
  local left = math.floor(stars.right) - stars.width
  
  -- need to draw left and right quad (wraparound split?)
  if left >= stars.width then
    -- left end
    stars.quad:setViewport(left, 0, 2*stars.width-left, stars.height)
    love.graphics.draw(stars.canvas, stars.quad, 0, 0)
  
    -- right end
    stars.quad:setViewport(0, 0, left - stars.width, stars.height)
    love.graphics.draw(stars.canvas, stars.quad, 2*stars.width-left, 0)
    
  else  
    stars.quad:setViewport(left, 0, stars.width, stars.height)
    love.graphics.draw(stars.canvas, stars.quad, 0, 0)
  end
end


stars.load = load
stars.update = update
stars.draw = draw

return stars
