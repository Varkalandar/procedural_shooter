-- 
-- "Harmonic Shooter" bullets
--
-- Author: Hj. Malthaner
-- Date: 2022/06/21
--


local function load(tracer, width, height)
	tracer.list = {}  -- bullet list
  tracer.top = 0 -- last active bullet
	tracer.width = width
	tracer.height = height
  tracer.color =
  {
    r=1, g=0.5, b=0.1
  }    
end


local function isActive(tracer, b)
  return 
    b.x > -10 and b.x < tracer.width + 10 and
    b.y > -10 and b.y < tracer.height + 10
end


local function purgeObsolete(tracer)
  for i=0, tracer.top-1 do
    local b = tracer.list[i]	
    if b.active then
      b.active = isActive(tracer, b)
	  end
  end
end


local function move(tracer)
  for i=0, tracer.top-1 do
    local b = tracer.list[i]	
    b.x = b.x + b.dx
    b.y = b.y + b.dy
  end
end


local function update(tracer, dt)
  purgeObsolete(tracer)
  move(tracer)
end


local function draw(tracer)
  for i=0, tracer.top-1 do
    local bullet = tracer.list[i]	
    
    if bullet.active then
      love.graphics.setColor(tracer.color.r*0.6, tracer.color.g*0.6, tracer.color.b*0.6, 1)
      love.graphics.rectangle('fill', math.floor(bullet.x)-2, math.floor(bullet.y)-1, 5, 3)
      love.graphics.setColor(tracer.color.r, tracer.color.g, tracer.color.b, 1)
      love.graphics.rectangle('fill', math.floor(bullet.x)-3, math.floor(bullet.y), 6, 1)
    end
    
  end
end


local function checkHits(tracer, x, y)
  for i=0, tracer.top-1 do
    local bullet = tracer.list[i]	
    
    if bullet.active then
      local dx = bullet.x - x
      local dy = bullet.y - y
      local d = dx*dx + dy*dy
      
      if d < 800 then
        return true
      end
    end
  end
  
  -- no bullet hit
  return false
end


local function add(tracer, x, y, dx, dy)
  -- scan for a free bullet slot
  for i=0, tracer.top-1 do
    local bullet = tracer.list[i]
    if bullet and not bullet.active then
      bullet.x = x
      bullet.y = y
      bullet.dx = dx
      bullet.dy = dy
      bullet.active = true
      return -- done
    end
  end
  
  -- we need to add one more bullet
  tracer.list[tracer.top] = {x=x, y=y, dx=dx, dy=dy, active = true}
  tracer.top = tracer.top + 1
end


local function makeNewTracer()
  tracer = {}
  tracer.load = load
  tracer.update = update
  tracer.draw = draw

  tracer.add = add
  tracer.checkHits = checkHits

  return tracer
end  

  
local bullets = {}
bullets.makeNewTracer = makeNewTracer  


return bullets
