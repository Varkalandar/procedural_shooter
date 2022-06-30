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


local function move(tracer, dt)
  for i=0, tracer.top-1 do
    local b = tracer.list[i]	
    b.x = b.x + b.dx * 60 * dt
    b.y = b.y + b.dy * 60 * dt
  end
end


local function update(tracer, dt)
  purgeObsolete(tracer)
  move(tracer, dt)
end


local function draw(tracer)
  for i=0, tracer.top-1 do
    local bullet = tracer.list[i]	    
    tracer.drawBullet(bullet)
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
        bullet.active = false
        return bullet
      end
    end
  end
  
  -- no bullet hit
  return nil
end


local function add(tracer, x, y, dx, dy, data)
  -- scan for a free bullet slot
  for i=0, tracer.top-1 do
    local bullet = tracer.list[i]
    if bullet and not bullet.active then
      bullet.x = x
      bullet.y = y
      bullet.dx = dx
      bullet.dy = dy
      bullet.data = data
      bullet.active = true      
      return -- done
    end
  end
  
  -- we need to add an additional bullet to the array
  tracer.list[tracer.top] = {x=x, y=y, dx=dx, dy=dy, data=data, active = true}
  tracer.top = tracer.top + 1
end


local function makeNewTracer(bulletDrawFunction)
  tracer = {}
  tracer.load = load
  tracer.update = update
  tracer.draw = draw

  tracer.add = add
  tracer.checkHits = checkHits
  tracer.drawBullet = bulletDrawFunction
  return tracer
end  

  
local bullets = {}
bullets.makeNewTracer = makeNewTracer  


return bullets
