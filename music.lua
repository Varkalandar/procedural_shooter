-- 
-- "Harmonic Shooter" music thread
--
-- Author: Hj. Malthaner
-- Date: 2022/06/22
--

require("love.timer")
require("love.audio")
require("love.sound")
require("love.math")

local sounds = require("sounds")

local snare =  
    sounds.make(180, -- duration
                sounds.pluckEnvelope, 
                256,
                0,  -- shift
                5,  -- harmonics,
                100, -- vibrato,
                50, -- vibratoAmount,
                0.7, -- noise,
                4  -- noiseFrequencyDivision
                )
snare:setVolume(0.1)

local bass =  
    sounds.make(400, -- duration
                sounds.pluckEnvelope, 
                64,
                0,  -- shift
                5,  -- harmonics,
                100, -- vibrato,
                50, -- vibratoAmount,
                0.7, -- noise,
                12  -- noiseFrequencyDivision
                )
bass:setVolume(0.12)


local synth =  
    sounds.make(8000, -- duration
                sounds.pluckEnvelope, 
                256,
                0,  -- shift
                6,  -- harmonics,
                50, -- vibrato,
                50, -- vibratoAmount,
                0, -- noise,
                6  -- noiseFrequencyDivision
                )
synth:setVolume(0.05)


local synthLow =  
    sounds.make(16000, -- duration
                sounds.pluckEnvelope, 
                32,
                0,  -- shift
                6,  -- harmonics,
                25, -- vibrato,
                50, -- vibratoAmount,
                0.1, -- noise,
                6  -- noiseFrequencyDivision
                )
synthLow:setVolume(0.14)


local synthHigh =  
    sounds.make(180, -- duration
                sounds.pluckEnvelope, 
                1024,
                0,  -- shift
                6,  -- harmonics,
                0, -- vibrato,
                0, -- vibratoAmount,
                0.1, -- noise,
                6  -- noiseFrequencyDivision
                )
synthHigh:setVolume(0.1)

local channel = love.thread.getChannel("control")
local nextBeat = love.timer.getTime() + 1
local beats = 0

local function synthPitch()
  local hitpoints = math.floor(love.math.random() * 8)
  local pitch = 1
  
  if hitpoints == 1 then
    pitch = 2
  elseif hitpoints == 2 then
    pitch =  5 / 3
  elseif hitpoints == 3 then
    pitch =  3 / 2
  elseif hitpoints == 4 then
    pitch =  4 / 3
  elseif hitpoints == 5 then
    pitch =  4 / 3
  elseif hitpoints == 6 then
    pitch =  5 / 4
  elseif hitpoints == 7 then
    pitch =  9 / 8
  end

  return pitch
end

synth:play()

while true do
  local message = channel:pop()

  if message == "stop" then
    print("Stopping music.")
    synth:stop()
    snare:stop()
    bass:stop()
    break
  end

  local t1 = love.timer.getTime()
  
  if t1 > nextBeat then
    nextBeat = love.timer.getTime() + 0.1
    local beat = beats % 4
    
    if beat == 0 then
      bass:play()
      
      if love.math.random() < 0.8 then
        synth:stop()
        synth:setPitch(synthPitch()) 
        synth:play()
      end

      if love.math.random() < 0.6 then
        synthLow:stop()
        synthLow:setPitch(synthPitch()) 
        synthLow:play()
      end

      if love.math.random() < 0.5 then
        synthHigh:stop()
        synthHigh:setPitch(synthPitch()) 
        synthHigh:play()
      end
    end

    if beat == 1 and love.math.random() < 0.2 then
      bass:stop()
      bass:play()
      if love.math.random() < 0.5 then
        synthHigh:stop()
        synthHigh:setPitch(synthPitch()) 
        synthHigh:play()
      end
    end
    
    if beat == 2 then
      snare:play()

      if love.math.random() < 0.4 then
        synth:stop()
        synth:setPitch(synthPitch()) 
        synth:play()
      end
      if love.math.random() < 0.5 then
        synthHigh:stop()
        synthHigh:setPitch(synthPitch()) 
        synthHigh:play()
      end
    end
    
    if beat == 3 and love.math.random() < 0.5 then
      snare:play()
      if love.math.random() < 0.5 then
        synthHigh:stop()
        synthHigh:setPitch(synthPitch()) 
        synthHigh:play()
      end
    end

    beats = beats + 1
  end

  love.timer.sleep(1/60)

end


return music
