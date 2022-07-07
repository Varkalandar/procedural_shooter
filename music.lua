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

-- global music volume
local amp = 0.3

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
snare:setVolume(0.1 * amp)

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
bass:setVolume(0.12 * amp)


local synth =  
    sounds.make(8000, -- duration
                sounds.pluckEnvelope, 
                256,
                0,  -- shift
                7,  -- harmonics,
                50, -- vibrato,
                50, -- vibratoAmount,
                0, -- noise,
                6  -- noiseFrequencyDivision
                )
synth:setVolume(0.05 * amp)


local synth2 =  
    sounds.make(8000, -- duration
                sounds.pluckEnvelope, 
                256,
                0,  -- shift
                6,  -- harmonics,
                100, -- vibrato,
                50, -- vibratoAmount,
                0, -- noise,
                6  -- noiseFrequencyDivision
                )
synth2:setVolume(0.05 * amp)


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
synthLow:setVolume(0.17 * amp)


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
synthHigh:setVolume(0.1 * amp)

local channel = love.thread.getChannel("control")
local nextBeat = love.timer.getTime() + 1
local beats = 0
local pause = false

local function synthPitch()
  local interval = math.floor(love.math.random() * 8)
  local pitch = 1
  
  if interval == 1 then
    pitch = 2
  elseif interval == 2 then
    pitch =  5 / 3
  elseif interval == 3 then
    pitch =  3 / 2
  elseif interval == 4 then
    pitch =  4 / 3
  elseif interval == 5 then
    pitch =  4 / 3
  elseif interval == 6 then
    pitch =  5 / 4
  elseif interval == 7 then
    pitch =  9 / 8
  end

  return pitch
end


local function playRandomSynthChord()
  local pitch = synthPitch()
  synth:stop()
  synth:setPitch(pitch) 
  synth:play()
  
  if love.math.random() < 0.3 then
    pitch = pitch * 4 / 3
    synth2:stop()
    synth2:setPitch(pitch) 
    synth2:play()    
  end
end


local function playRandomMusic()
  local beat = beats % 8
  
  if beat == 0 then
    bass:play()
    
    if love.math.random() < 0.8 then
      playRandomSynthChord()
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

  if beat == 2 and love.math.random() < 0.2 then
    bass:stop()
    bass:play()
    if love.math.random() < 0.5 then
      synthHigh:stop()
      synthHigh:setPitch(synthPitch()) 
      synthHigh:play()
    end
  end
  
  if beat == 4 then
    snare:play()

    if love.math.random() < 0.4 then
      playRandomSynthChord()
    end
    if love.math.random() < 0.5 then
      synthHigh:stop()
      synthHigh:setPitch(synthPitch()) 
      synthHigh:play()
    end
  end
  
  if beat == 6 and love.math.random() < 0.5 then
    snare:play()
    if love.math.random() < 0.5 then
      synthHigh:stop()
      synthHigh:setPitch(synthPitch()) 
      synthHigh:play()
    end
  end
end


while true do
  local message = channel:pop()

  if message then
    if message == "stop" then
      print("Stopping music.")
      break
    elseif message == "togglePause" then
      print("Toggling music.")
      pause = not pause
    end
  end
  
  local t1 = love.timer.getTime()
  
  if t1 > nextBeat and not pause then
    nextBeat = t1 + 0.05
    playRandomMusic(beats)
    beats = beats + 1
  end

  love.timer.sleep(0.05)
end


return music
