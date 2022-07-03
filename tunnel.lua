-- 
-- "Harmonic Shooter" tunnel file
--
-- Author: Hj. Malthaner
-- Date: 2022/06/14
--

local tunnel = {}


local function colorGradient()
  return love.math.random() * 0.0006 - 0.0003
end


local function wallGradient()
  return love.math.random() * 3.0 - 1.5
end


local function load(width, height)

  tunnel.width = width
  tunnel.height = height
  tunnel.topY = {}
  tunnel.bottomY = {}
  
  -- works as wraparound ring buffer
  tunnel.canvas = love.graphics.newCanvas(width*2, height)

  -- the visible area of the tunnel
  tunnel.quad = love.graphics.newQuad(0, 0, width, height, 
                                      tunnel.canvas)

  -- scroll speed, pixels per second
  tunnel.speed = 60
  tunnel.right = width - 1
  tunnel.depth = -1000
  
  love.graphics.setCanvas(canvas)
  love.graphics.clear()
  love.graphics.setBlendMode("alpha")
  love.graphics.setColor(0, 0, 1, 1)
  love.graphics.rectangle('fill', 0, 0, width, height)
  love.graphics.setCanvas()  

  -- color vector stuff

  tunnel.red = 0.20
  tunnel.green = 0.20 
  tunnel.blue = 0.20

  tunnel.rv = colorGradient()
  tunnel.gv = colorGradient()
  tunnel.bv = colorGradient()

  -- wall vector stuff

  tunnel.top = 70 
  tunnel.bottom = height - 70  
  tunnel.topv = wallGradient()
  tunnel.bottomv = wallGradient()   

  for x=0, 2*tunnel.width-1 do
    tunnel.topY[x] = 0
    tunnel.bottomY[x] = 0
  end
end


local function update(dt)
  local r1 = math.floor(tunnel.right)
  local vd =  dt * tunnel.speed
  tunnel.right = tunnel.right + vd
  tunnel.depth = tunnel.depth + vd
  local r2 = math.floor(tunnel.right)

  for x=r1, r2-1 do

    local xm = x % (2*tunnel.width)
    
    -- random color vector changes
    if love.math.random() < 0.002 then
      tunnel.rv = colorGradient()
    end
    
    if love.math.random() < 0.002 then
      tunnel.gv = colorGradient()
    end
    
    if love.math.random() < 0.002 then
      tunnel.bv = colorGradient()
    end


    -- wall changes
    if love.math.random() < 0.25 then
      tunnel.topv = wallGradient()
    end

    if love.math.random() < 0.25 then
      tunnel.bottomv = wallGradient()
    end
    
    
    -- wall vectors, check bounds    
    local top = tunnel.top + tunnel.topv
    if top < 20 then
      tunnel.topv = -tunnel.topv
      top = top +1
    end
    
    if top > 180 then
      tunnel.topv = -tunnel.topv
      top = top - 1
    end
    
    local bottom = tunnel.bottom + tunnel.bottomv
    if bottom > tunnel.height - 20 then
      tunnel.bottomv = -tunnel.bottomv
      bottom = bottom - 1
    end

    if bottom < tunnel.height - 180 then
      tunnel.bottomv = -tunnel.bottomv
      bottom = bottom + 1
    end
    
    -- color vectors, check out of bounds stuff    
    local red = tunnel.red + tunnel.rv
    while red < 0.15 or red > 0.25 do
      tunnel.rv = colorGradient()
      red = tunnel.red + tunnel.rv
    end
    
    local green = tunnel.green + tunnel.gv
    while green < 0.15 or green > 0.25 do
      tunnel.gv = colorGradient()
      green = tunnel.green + tunnel.gv
    end
    
    local blue = tunnel.blue + tunnel.bv
    while blue < 0.15 or blue > 0.25 do
      tunnel.bv = colorGradient()
      blue = tunnel.blue + tunnel.bv
    end
      
      
    -- now, draw
    
    love.graphics.setCanvas(tunnel.canvas)  
    love.graphics.setColor(red*0.6, green*0.3, blue*1.0, 1)

    -- walls
    vline(xm, 0, top-1)
    vline(xm, bottom+1, tunnel.height-bottom)
    
    -- border
    love.graphics.setColor(red*0.9, green*0.45, blue*1.5, 0.5)
    vline(xm, top-3, 4)
    vline(xm, bottom, 3)

    -- center must be cleared 'ahead' by one pixel, to allow stars
    love.graphics.setColor(0, 0, 0, 1)
    vline(xm+1, 0, tunnel.height)

    -- stars
    for y = top, bottom do
      if love.math.random() < 0.002 then
        local lum = love.math.random() * 0.6 + 0.1

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
      if love.math.random() < 0.0002 then
        -- very big star
        local b = love.math.random() * 0.6 + 0.2
        love.graphics.setColor(b, b, b, 0.7)
        vline(xm, y-1, 3)
        vline(xm-1, y, 1)
        vline(xm+1, y, 1)
        love.graphics.setColor(b, b, b, 1)
        vline(xm, y, 1)
      end
    end
    
    love.graphics.setCanvas()    
    
    tunnel.red = red
    tunnel.green = green
    tunnel.blue = blue
    
    tunnel.top = top
    tunnel.bottom = bottom

    -- record wall positions at x
    tunnel.topY[xm] = top
    tunnel.bottomY[xm] = bottom
    
    -- print("recording " .. xm .. " t=" .. top .. " b=" .. bottom)
  end
  
  -- wrap
  if tunnel.right >= 3*tunnel.width then  
    tunnel.right = tunnel.right - 2*tunnel.width
  end  
end


local function draw()
  love.graphics.setColor(1, 1, 1, 1)
  local left = math.floor(tunnel.right) - tunnel.width
  
  -- need to draw left and right quad (wraparound split?)
  if left >= tunnel.width then
    -- left end
    tunnel.quad:setViewport(left, 0, 2*tunnel.width-left, tunnel.height)
    love.graphics.draw(tunnel.canvas, tunnel.quad, 0, 0)
  
    -- right end
    tunnel.quad:setViewport(0, 0, left - tunnel.width, tunnel.height)
    love.graphics.draw(tunnel.canvas, tunnel.quad, 2*tunnel.width-left, 0)
    
  else  
    tunnel.quad:setViewport(left, 0, tunnel.width, tunnel.height)
    love.graphics.draw(tunnel.canvas, tunnel.quad, 0, 0)
  end
  
  love.graphics.setFont(fonts.normal)
  love.graphics.print(math.floor(tunnel.depth * 0.15) .. " Meters", 10, 10)  
end


tunnel.load = load
tunnel.update = update
tunnel.draw = draw

return tunnel
