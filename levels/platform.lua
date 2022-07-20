-- 
-- "Harmonic Shooter" land file
--
-- Author: Hj. Malthaner
-- Date: 2022/06/14
--

local colorGradient = require("color_gradient")

local land = {}


local function wSetpix(x, y, wrap)
  love.graphics.rectangle('fill', x % wrap, y, 1, 1)
end


local function wVline(x, y, h, wrap)
  love.graphics.rectangle('fill', x % wrap, y, 1, h)
end


local function wHline(x, y, w, wrap)
  for i=x, x+w do
    wSetpix(i, y, wrap)
  end
end


local function drawBevelUp(color, left, top, w, h, rise)
  -- center
  local bright = 0.5
  love.graphics.setColor(color.r * bright, color.g * bright, color.b * bright, 0.9)    
  love.graphics.rectangle('fill', left, top, w, h)

  for line = 1, rise do
    -- darker sides
    bright = 0.05
    love.graphics.setColor(color.r * bright, color.g * bright, color.b * bright * 1.1, 0.9)    
    hline(left+line, top + h - line, w-line-line+1)
    bright = 0.07
    love.graphics.setColor(color.r * bright, color.g * bright, color.b * bright * 1.1, 0.9)    
    vline(left+w-line, top + line, h-line-line+1)
    
    -- brighter sides
    bright = 0.8
    love.graphics.setColor(color.r * bright, color.g * bright, color.b * bright * 0.9, 0.9)
    hline(left+line, top + line, w-line-line+1)
    bright = 0.6
    love.graphics.setColor(color.r * bright, color.g * bright, color.b * bright * 0.9, 0.9)    
    vline(left+line, top + line, h-line-line+1)
  end
end


local function drawBevelDown(color, left, top, w, h, rise)
  -- center
  local bright = 0.5
  love.graphics.setColor(color.r * bright, color.g * bright, color.b * bright, 0.9)    
  love.graphics.rectangle('fill', left, top, w, h)

  for line = 1, rise do
    -- brighter sides
    bright = 0.8
    love.graphics.setColor(color.r * bright, color.g * bright, color.b * bright * 1.1, 0.9)    
    hline(left+line, top + h - line, w-line-line+1)
    bright = 0.6
    love.graphics.setColor(color.r * bright, color.g * bright, color.b * bright * 1.1, 0.9)    
    vline(left+w-line, top + line, h-line-line+1)
    
    -- darker sides
    bright = 0.05
    love.graphics.setColor(color.r * bright, color.g * bright, color.b * bright * 0.9, 0.9)
    hline(left+line, top + line, w-line-line+1)
    bright = 0.07
    love.graphics.setColor(color.r * bright, color.g * bright, color.b * bright * 0.9, 0.9)    
    vline(left+line, top + line, h-line-line+1)
  end
end


local function drawPyramid(color, cx, cy, rise)
  for line = 0, rise do
    -- brighter sides
    local bright = 0.8
    love.graphics.setColor(color.r * bright, color.g * bright, color.b * bright * 1.1, 0.9)    
    hline(cx - line-1, cy - line, line+line+1)
    bright = 0.6
    love.graphics.setColor(color.r * bright, color.g * bright, color.b * bright * 1.1, 0.9)    
    vline(cx - line, cy - line, line+line)
    
    -- darker sides
    bright = 0.05
    love.graphics.setColor(color.r * bright, color.g * bright, color.b * bright * 0.9, 0.9)
    hline(cx - line, cy + line, line+line+1)
    bright = 0.1
    love.graphics.setColor(color.r * bright, color.g * bright, color.b * bright * 0.9, 0.9)
    vline(cx + line, cy - line, line+line)
  end
end


local function load(width, height)
  print("Initializing space platform level background")

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
  local color = {r = 0.22, g = 0.24, b = 0.38}
  -- local color = {r = 0.29, g = 0.18, b = 0.15}

  land.gradient = 
    colorGradient.make({r=0.01, g=0.01, b=0.01},  -- velocity of change
                       color,  -- starting color
                       {r=0.15, g=0.10, b=0.15},  -- min allowed values           
                       {r=0.3, g=0.3, b=0.4}  -- max allowed values
                       )
  
  love.graphics.setCanvas(canvas)
  love.graphics.clear()
  love.graphics.setBlendMode("alpha")
  love.graphics.setCanvas()  

  for x=0, 2*land.width-1 do
    land.topY[x] = 30
    land.bottomY[x] = height-31
  end
end


local function gridHole(color, x, y)
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
    love.graphics.setColor(color.r * bright, color.g * bright, color.b * bright * 1.1, 1)    
    hline(left+line, top + h - line, w-line-line+1)
    vline(left+w-line, top + line, h-line-line+1)
    
    -- darker sides
    bright = bright * 0.7
    love.graphics.setColor(color.r * bright, color.g * bright, color.b * bright * 0.9, 1)    
    hline(left+line, top + line-1, w-line-line+1)
    vline(left+line-1, top + line-1, h-line-line+2)
  end

  love.graphics.setBlendMode("alpha")
end


local function gridBlock(color, x, y)

  local mx = 5 + math.floor(love.math.random() * 50)
  local my = 5 + math.floor(love.math.random() * 50)
  local left = x + 2*mx - math.floor(love.math.random() * 2*mx)
  local top = y + 2*my - math.floor(love.math.random() * 2*my)
  local w = land.gridW - mx - mx
  local h = land.gridH - my - my

  local rise = 1 + math.floor(love.math.random() * 3)

  drawBevelUp(color, left, top, w, h, rise)
end


local function gridFlat(color, x, y)

  local mx = 5 + math.floor(love.math.random() * 50)
  local my = 5 + math.floor(love.math.random() * 50)
  local left = x + 2*mx - math.floor(love.math.random() * 2*mx)
  local top = y + 2*my - math.floor(love.math.random() * 2*my)
  local w = land.gridW - mx - mx
  local h = land.gridH - my - my

  local rise = 1 + math.floor(love.math.random() * 2)

  drawBevelDown(color, left, top, w, h, rise)
end


local function gridPyramid(color, x, y)

  local cx = x + land.gridW/2 + math.floor(love.math.random() * land.gridW * 0.3)
  local cy = y + land.gridH/2 + math.floor(love.math.random() * land.gridH * 0.3)

  local rise = 5 + math.floor(love.math.random() * 15)

  drawPyramid(color, cx, cy, rise)
end


local function gridPyramidGroup(color, x, y)

  local cx = x + land.gridW/2 + math.floor(love.math.random() * land.gridW * 0.3)
  local cy = y + land.gridH/2 + math.floor(love.math.random() * land.gridH * 0.3)
  
  local rise = 2 + math.floor(love.math.random() * 3)
  local rows = 1 + math.floor(love.math.random() * 2)
  local cols = 1 + math.floor(love.math.random() * 2)
  local space = 1 + math.floor(love.math.random() * 9)
  
  drawBevelDown(color, 
                          cx - rows*(rise*2 + space) - rise - 4, cy-cols*(rise*2 + space) - rise - 4, 
                          rows*(rise*2 + space) * 2 + rise*2 + 8, cols*(rise*2 + space) * 2 + rise*2 + 8,
                          1)
  
  for r=-rows, rows do
    for c=-cols, cols do
      drawPyramid(color, cx + r*(rise*2 + space), cy+c*(rise*2 + space), rise)
    end
  end
end


local function gridCylinder(color, x, y)
  local mx = 30 + math.floor(love.math.random() * 30)
  local my = 30 + math.floor(love.math.random() * 30)
  local left = x + 2*mx - math.floor(love.math.random() * 2*mx)
  local top = y + 2*my - math.floor(love.math.random() * 2*my)
  local w = land.gridW - mx - mx
  local h = land.gridH - my - my
  
  if love.math.random() < 0.5 then
    for line = 1, h do
      local bright = 0.12 + math.sqrt(1 - line / h) * 0.6
      love.graphics.setColor(color.r * bright, color.g * bright, color.b * bright, 1)
      hline(left, top + line, w)
    end
  else
    for line = 1, h do
      local bright = 0.10 + math.sqrt(1 - line / h) * 0.6
      love.graphics.setColor(color.r * bright, color.g * bright, color.b * bright, 1)
      vline(left+line, top, w)
    end
  end
end


local function makeRandomStructure(color, x, row, jitter)
  local r = love.math.random()
  if r < 0.5 then
    gridHole(color, x % (2*land.width), row*land.gridH + jitter)
  elseif r < 0.55 then
    gridBlock(color, x % (2*land.width), row*land.gridH + jitter)
  elseif r < 0.59 then
    gridCylinder(color, x % (2*land.width), row*land.gridH + jitter)
  elseif r < 0.64 then
    gridPyramid(color, x % (2*land.width), row*land.gridH + jitter)
  elseif r < 0.68 then
    gridPyramidGroup(color, x % (2*land.width), row*land.gridH + jitter)
  elseif r < 0.72 then
    gridFlat(color, x % (2*land.width), row*land.gridH + jitter)
  end
end


local function makeRandomLines(color, x, wrap)
  local yr = math.floor(love.math.random() * land.height * 0.2) * 5
  local xr = math.floor(x * 0.2) * 5
  local bright = 0.8 + love.math.random() * 0.7
  local len = math.floor(love.math.random() * 20) * 5

  love.graphics.setScissor(0, 33, land.width*2, land.height-66)
  if love.math.random() < 0.5 then
    love.graphics.setColor(0, 0, 0, 0.6)    
    wVline(land.gridW + xr, yr, len, wrap)
    love.graphics.setColor(color.r * bright, color.g * bright, color.b * bright, 0.5)    
    wVline(land.gridW + xr + 1, yr, len, wrap)
  else
    love.graphics.setColor(0, 0, 0, 0.5)    
    wHline(land.gridW + xr, yr, len, wrap)    
    love.graphics.setColor(color.r * bright, color.g * bright, color.b * bright, 0.5)    
    wHline(land.gridW + xr, yr+1, len, wrap)   
  end
  love.graphics.setScissor()
end


local function update(dt)
  local r1 = math.floor(land.right)
  local vd =  dt * land.speed
  land.right = land.right + vd
  land.depth = land.depth + vd
  local r2 = math.floor(land.right)
  local wrap = 2*land.width
  
  land.gradient:update(dt)
  local color = land.gradient.color
  
  love.graphics.setCanvas(land.canvas)  
  
  love.graphics.setBlendMode("alpha")
  
  for x=r1, r2-1 do

    -- draw random lines, leave space for big structures
    -- which later will be drawn over the random lines
    if love.math.random() < 0.4 then
      makeRandomLines(color, x, wrap)
    end

    -- check and draw structures
    if (x % land.gridW) == 0 then
      local jitter = math.floor(land.gridH * 0.25 + love.math.random() * land.gridH * 0.5)
    
      for row = 0, 3 do
        makeRandomStructure(color, x, row, jitter)
      end
    end

    -- clear past left border of visible field
    local dim = 0.3 + love.math.random() * 0.2 
    local jitter = math.floor(love.math.random() * 3)
    
    -- dark side
    love.graphics.setColor(color.r * dim * 0.8, color.g * dim * 0.8, color.b * dim * 0.9, 1)    
    vline((x-land.width) % (2*land.width), 0, 30 + jitter)

    love.graphics.setColor(color.r * dim, color.g * dim, color.b * dim, 1)    
    vline((x-land.width) % (2*land.width), 30 + jitter, land.height-60)

    -- bright side
    love.graphics.setColor(color.r * dim * 1.4, color.g * dim * 1.4, color.b * dim * 1.3, 1)    
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
