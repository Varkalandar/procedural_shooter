-- 
-- "Harmonic Shooter" sound generator
--
-- Author: Hj. Malthaner
-- Date: 2022/06/21
--

local sounds = {}

local SAMPLE_RATE = 44100


local function noise(d, level)
  local noise = 0

  for i=1, d do
    noise = noise + (love.math.random() - 0.5) * noiseLevel * 2
  end
  
  return noise/d
end


local function clip(v)
  if v > 1 then
    print("Clipping .. " .. v)
    v = 1
  end
  if v < -1 then
    print("Clipping .. " .. v)
    v = -1
  end
  return v
end


local function make(length,  -- seconds?
                             envelope, 
                             frequency, 
                             fshift,
                             harmonics,
                             vibrato,
                             vibratoAmount,
                             noiseLevel, 
                             noiseStep)
  local samples = math.floor(SAMPLE_RATE * length / 1000)

  print("samples=" .. samples)
  
  local soundData = love.sound.newSoundData(samples, rate, 16, 1)
  
  -- there need to be frequency count periods in one second
  -- a period is Math.PI * 2 units long.
        
  local r = frequency * math.pi * 2.0 / SAMPLE_RATE

  local hsum = 0
  for h=1,harmonics do
    hsum = hsum + 1.0/ h
  end
  hsum = 1/hsum
        
  -- we start with the noise
  local lastNoise = ((love.math.random() - 0.5) * noiseLevel * 2)

  for  i=0,samples-noiseStep-1,noiseStep do
    local currNoise = ((love.math.random() - 0.5) * noiseLevel * 2)
            
    for n=0,noiseStep-1 do
      local nv = (lastNoise + (currNoise - lastNoise) * n / noiseStep) 
      
      -- print("nv=" .. nv)
      soundData:setSample(i+n, clip(nv))  
      lastNoise = currNoise
    end
  end
  
  -- now add the wave
  local fs = 1.0  -- frequency shift
  
  for i=0,samples-1 do
    local v = 0
    fs = fs + fs * fshift * 0.0000001
          
    for h=1,harmonics do
      local f = i * fs
      v = v + math.sin((f * r * h)) * (1 - noiseLevel) / h;
    end
    
    v = v * hsum            
    v = v + soundData:getSample(i) -- keep the noise

    local double av = vibratoAmount / 100.0
    v = v * 0.5 * envelope(i, samples) * (1-av*0.5) *  (1 + math.sin(i * vibrato * math.pi * 2 / samples) * av)
          
    v = clip(v)
    
    soundData:setSample(i, v)
  end
  
  return love.audio.newSource(soundData)
end


local function pluckEnvelope(sample, count)
  local scale = math.pi / math.log(1+count);
  return math.sin(scale * math.log(1+sample));
end


sounds.pluckEnvelope = pluckEnvelope
sounds.make = make

return sounds

