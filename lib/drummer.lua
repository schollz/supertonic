local Drummer={}


function Drummer:debug(s)
  if mode_debug then
    print("part: "..s)
  end
end


function Drummer:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  self.enabled=false
  self.name=o.name 
  return o
end

function Drummer:set_patch(patch)
  self.patch=patch
end

function Drummer:set_pattern(pattern_string)
  self.pattern_string=pattern_string
  self.pattern=self:xox(pattern_string)
end

function Drummer:enable()
  if self.patch == nil or self.pattern==nil then 
    do return end 
  end
  self.enabled=true
end

function Drummer:disable()
  self.enabled=false 
end

function Drummer:step(beat)
  if not self.enabled then 
    do return false end
  end
  if self.pattern(beat) then
    engine.nanotonic(
      self.patch.distAmt,
      self.patch.eQFreq,
      self.patch.eQGain,
      self.patch.level,
      self.patch.mix,
      self.patch.modAmt,
      self.patch.modMode,
      self.patch.modRate,
      self.patch.nEnvAtk,
      self.patch.nEnvDcy,
      self.patch.nEnvMod,
      self.patch.nFilFrq,
      self.patch.nFilMod,
      self.patch.nFilQ,
      self.patch.nStereo,
      self.patch.oscAtk,
      self.patch.oscDcy,
      self.patch.oscFreq,
      self.patch.oscWave,
    )
  end
  return true
end

function Drummer:xox(riddim)
  -- return riddim detector
  -- beat starts on 1
  return function (beat)
    beat = ((beat-1) % #riddim) + 1
    return riddim:sub(beat, beat) ~= '-'
  end
end


return Drummer