-- 
-- "Harmonic Shooter" color gradient
--
-- Author: Hj. Malthaner
-- Date: 2022/06/14
--


local function v(maxV)
  return love.math.random() * maxV*2 - maxV
end

local function update(cg, dt)

  -- advance color gradient, do bounds checks
  local red = cg.color.r + cg.v.r * dt
  while red < cg.min.r or red > cg.max.r do
    cg.v.r = v(cg.maxV.r)
    red = cg.color.r + cg.v.r * dt
  end
  
  local green = cg.color.g + cg.v.g * dt
  while green < cg.min.g or green > cg.max.g do
    cg.v.g = v(cg.maxV.g)
    green = cg.color.g + cg.v.g * dt
  end
  
  local blue = cg.color.b + cg.v.b * dt
  while blue < cg.min.b or blue > cg.max.b do
    cg.v.b = v(cg.maxV.b)
    blue = cg.color.b + cg.v.b * dt
  end

  cg.color.r = red
  cg.color.g = green
  cg.color.b = blue
  
  -- random color vector changes
  if love.math.random() < 0.002 then
    cg.v.r = v(cg.maxV.r)
  end
  
  if love.math.random() < 0.002 then
    cg.v.g = v(cg.maxV.g)
  end
  
  if love.math.random() < 0.002 then
    cg.v.b = v(cg.maxV.b)
  end
  
  return cg.color
end


local gradientMaker = {}

local function make(maxV, rgb, rgbMin, rgbMax)

  local gradient = {}
  gradient.maxV = {r=maxV.r, g=maxV.g, b=maxV.b}

  gradient.color = {r=rgb.r, g=rgb.g, b=rgb.b}
  gradient.min = {r=rgbMin.r, g=rgbMin.g, b=rgbMin.b}
  gradient.max = {r=rgbMax.r, g=rgbMax.g, b=rgbMax.b}
  gradient.v = {r=v(gradient.maxV.r), g=v(gradient.maxV.g), b=v(gradient.maxV.b)}
  gradient.update = update

  return gradient
end


gradientMaker.make = make

return gradientMaker