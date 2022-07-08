-- 
-- "Harmonic Shooter" land file
--
-- Author: Hj. Malthaner
-- Date: 2022/06/14
--

local land = {}


local function wSetpix(x, y, wrap)
  love.graphics.rectangle('fill', x % wrap, y, 1, 1)
end


local function wVline(x, y, h, wrap)
  love.graphics.rectangle('fill', x % wrap, y, 1, h)
end


function wHline(x, y, w, wrap)
  for i=x, x+w do
    wSetpix(i, y, wrap)
  end
end


local function load(width, height)

  land.width = width
  land.height = height
  land.topY = {}
  land.bottomY = {}
  land.gridH = height / 5
  land.gridW = width / 8
  
  -- works as wraparound ring buffer
  land.canvas = love.graphics.newCanvas(width*2, height)

  -- the visible area of the land
  land.quad = love.graphics.newQuad(0, 0, width, height, 
                                      land.canvas)

  -- scroll speed, pixels per second
  land.speed = 60
  land.right = width - 1
  land.depth = -1000
  land.color = {r = 0.22, g = 0.24, b = 0.38}
  land.color = {r = 0.29, g = 0.18, b = 0.15}

  love.graphics.setCanvas(canvas)
  love.graphics.clear()
  love.graphics.setBlendMode("alpha")
  love.graphics.setCanvas()  


  for x=0, 2*land.width-1 do
    land.topY[x] = 0
    land.bottomY[x] = height-1
  end
end


local function gridHole(x, y)
  love.graphics.setBlendMode("replace")
  love.graphics.setColor(0, 0, 0, 0)
  local mx = 2 + math.floor(love.math.random() * 50)
  local my = 2 + math.floor(love.math.random() * 50)
  local left = x + 2*mx - math.floor(love.math.random() * 2*mx)
  local top = y + 2*my - math.floor(love.math.random() * 2*my)
  local w = land.gridW - mx - mx
  local h = land.gridH - my - my
  
  love.graphics.rectangle('fill', left, top, w, h)

  for line = 1, 7 do
    local bright = (10 - line) * 0.1
    
    -- brighter sides
    love.graphics.setColor(land.color.r * bright, land.color.g * bright, land.color.b * bright * 1.1, 1)    
    hline(left+line, top + h - line, w-line-line+1)
    vline(left+w-line, top + line, h-line-line+1)
    
    -- darker sides
    bright = bright * 0.7
    love.graphics.setColor(land.color.r * bright, land.color.g * bright, land.color.b * bright * 0.9, 1)    
    hline(left+line, top + line, w-line-line+1)
    vline(left+line, top + line, h-line-line+1)
  end

  love.graphics.setBlendMode("alpha")
end


local function gridBlock(x, y)

  local mx = 5 + math.floor(love.math.random() * 50)
  local my = 5 + math.floor(love.math.random() * 50)
  local left = x + 2*mx - math.floor(love.math.random() * 2*mx)
  local top = y + 2*my - math.floor(love.math.random() * 2*my)
  local w = land.gridW - mx - mx
  local h = land.gridH - my - my

  local rise = 1 + math.floor(love.math.random() * 3)

  -- center
  local bright = 0.5
  love.graphics.setColor(land.color.r * bright, land.color.g * bright, land.color.b * bright, 0.9)    
  love.graphics.rectangle('fill', left, top, w, h)

  for line = 1, rise do
    -- darker sides
    bright = 0.05
    love.graphics.setColor(land.color.r * bright, land.color.g * bright, land.color.b * bright * 1.1, 0.9)    
    hline(left+line, top + h - line, w-line-line+1)
    bright = 0.07
    love.graphics.setColor(land.color.r * bright, land.color.g * bright, land.color.b * bright * 1.1, 0.9)    
    vline(left+w-line, top + line, h-line-line+1)
    
    -- brighter sides
    bright = 0.8
    love.graphics.setColor(land.color.r * bright, land.color.g * bright, land.color.b * bright * 0.9, 0.9)
    hline(left+line, top + line, w-line-line+1)
    bright = 0.6
    love.graphics.setColor(land.color.r * bright, land.color.g * bright, land.color.b * bright * 0.9, 0.9)    
    vline(left+line, top + line, h-line-line+1)
  end
end


local function gridPyramid(x, y)

  local cx = x + land.gridW/2 + math.floor(love.math.random() * land.gridW * 0.3)
  local cy = y + land.gridH/2 + math.floor(love.math.random() * land.gridH * 0.3)

  local rise = 5 + math.floor(love.math.random() * 15)


  for line = 0, rise do
    -- brighter sides
    bright = 0.8
    love.graphics.setColor(land.color.r * bright, land.color.g * bright, land.color.b * bright * 1.1, 0.9)    
    hline(cx - line, cy - line, line+line)
    bright = 0.6
    love.graphics.setColor(land.color.r * bright, land.color.g * bright, land.color.b * bright * 1.1, 0.9)    
    vline(cx - line, cy - line, line+line)
    
    -- darker sides
    bright = 0.05
    love.graphics.setColor(land.color.r * bright, land.color.g * bright, land.color.b * bright * 0.9, 0.9)
    hline(cx - line, cy + line, line+line)
    bright = 0.1
    love.graphics.setColor(land.color.r * bright, land.color.g * bright, land.color.b * bright * 0.9, 0.9)
    vline(cx + line, cy - line, line+line)
  end
end


local function gridCylinder(x, y)
  local mx = 5 + math.floor(love.math.random() * 40)
  local my = 5 + math.floor(love.math.random() * 40)
  local left = x + 2*mx - math.floor(love.math.random() * 2*mx)
  local top = y + 2*my - math.floor(love.math.random() * 2*my)
  local w = land.gridW - mx - mx
  local h = land.gridH - my - my
  
  for line = 1, h do
    local bright = 0.12 + math.sqrt(1 - line / h) * 0.6
    love.graphics.setColor(land.color.r * bright, land.color.g * bright, land.color.b * bright, 0.5)    
    hline(left, top + line, w)
  end
end


local function update(dt)
  local r1 = math.floor(land.right)
  local vd =  dt * land.speed
  land.right = land.right + vd
  land.depth = land.depth + vd
  local r2 = math.floor(land.right)
  local wrap = 2*land.width
  
  love.graphics.setCanvas(land.canvas)  
  
  love.graphics.setBlendMode("alpha")
  
  for x=r1, r2-1 do

    -- love.graphics.setColor(0, 0, 0, 1)
    
    local y = math.floor(love.math.random() * land.height)

    -- draw random lines, leave space for big structures
    -- which later will be drawn over the random lines
    
    love.graphics.setScissor(0, 33, land.width*2, land.height-66)
    
    if love.math.random() < 0.5 then
      local bright = 0.8 + love.math.random() * 0.7
      if love.math.random() < 0.5 then
        local len = math.floor(love.math.random() * 100)
        love.graphics.setColor(0, 0, 0, 0.5)    
        wVline(land.gridW + x, y, len, wrap)
        love.graphics.setColor(land.color.r * bright, land.color.g * bright, land.color.b * bright, 0.5)    
        -- love.graphics.setColor(0.3 * bright, 0.2 * bright, 0.1 * bright, 1)    
        -- love.graphics.setColor(0.2 * bright, 0.1 * bright, 0.3 * bright, 1)    
        -- love.graphics.setColor(0.3 * bright, 0.1 * bright, 0 * bright, 1)    
        wVline(land.gridW + x + 1, y, len, wrap)
      else
        local len = math.floor(love.math.random() * 100)
        love.graphics.setColor(0, 0, 0, 0.5)    
        wHline(land.gridW + x, y, len, wrap)    
        love.graphics.setColor(land.color.r * bright, land.color.g * bright, land.color.b * bright, 0.5)    
        -- love.graphics.setColor(0.3 * bright, 0.2 * bright, 0.1 * bright, 1)    
        -- love.graphics.setColor(0.2 * bright, 0.1 * bright, 0.3 * bright, 1)    
        -- love.graphics.setColor(0.3 * bright, 0.1 * bright, 0 * bright, 1)    
        wHline(land.gridW + x, y+1, len, wrap)   
      end
    end

    love.graphics.setScissor()
    
    -- check and draw structures
    if (x % land.gridW) == 0 then
      local jitter = math.floor(land.gridH * 0.25 + love.math.random() * land.gridH * 0.5)
    
      for row = 0, 3 do
        local r = love.math.random()
        if r < 0.4 then
          gridHole(x % (2*land.width), row*land.gridH + jitter)
        elseif r < 0.5 then
          gridBlock(x % (2*land.width), row*land.gridH + jitter)
        elseif r < 0.55 then
          gridCylinder(x % (2*land.width), row*land.gridH + jitter)
        elseif r < 0.7 then
          gridPyramid(x % (2*land.width), row*land.gridH + jitter)
        end
      end
    end
    
    
    -- clear past left border of visible field
    local dim = 0.2 + love.math.random() * 0.4 
    local jitter = math.floor(love.math.random() * 3)
    
    -- dark side
    love.graphics.setColor(land.color.r * dim * 0.8, land.color.g * dim * 0.8, land.color.b * dim * 0.9, 1)    
    vline((x-land.width) % (2*land.width), 0, 30 + jitter)

    love.graphics.setColor(land.color.r * dim, land.color.g * dim, land.color.b * dim, 1)    
    vline((x-land.width) % (2*land.width), 30 + jitter, land.height-60)

    -- bright side
    love.graphics.setColor(land.color.r * dim * 1.4, land.color.g * dim * 1.4, land.color.b * dim * 1.3, 1)    
    vline((x-land.width) % (2*land.width), land.height-30 + jitter, 30)
  end

  love.graphics.setCanvas()
  
  -- wrap
  if land.right >= 3*land.width then  
    land.right = land.right - 2*land.width
  end  
end


local function draw()
  love.graphics.setColor(1, 1, 1, 1)
  local left = math.floor(land.right) - land.width
  
  -- need to draw left and right quad (wraparound split?)
  if left >= land.width then
    -- left end
    land.quad:setViewport(left, 0, 2*land.width-left, land.height)
    love.graphics.draw(land.canvas, land.quad, 0, 0)
  
    -- right end
    land.quad:setViewport(0, 0, left - land.width, land.height)
    love.graphics.draw(land.canvas, land.quad, 2*land.width-left, 0)
    
  else  
    land.quad:setViewport(left, 0, land.width, land.height)
    love.graphics.draw(land.canvas, land.quad, 0, 0)
  end
  
  love.graphics.setFont(fonts.normal)
  love.graphics.print(math.floor(land.depth * 0.15) .. " Meters", 10, 10)  
end


land.load = load
land.update = update
land.draw = draw

return land
