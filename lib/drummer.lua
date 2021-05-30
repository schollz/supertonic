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
  self.id=o.id
  self.name=o.name 
  o:set_pattern("--------------------------------")
  return o
end

function Drummer:set_patch(patch)
  for k,v in pairs(patch) do
    if k~="name" then
      params:set(self.id..k,v)
    end
  end
end

function Drummer:set_pattern(pattern_string)
  params:set(self.id.."pattern",pattern_string)
  self.pattern_string=pattern_string
  self.pattern=self:xox(pattern_string)
end

function Drummer:toggle_pattern(pos)
  pos=math.floor(pos)
  local current=self.pattern_string:sub(pos,pos)
  if current=="-" then
    current="x"
  else
    current="-"
  end
  self:set_pattern(self.pattern_string:sub(0,pos-1)..current..self.pattern_string:sub(pos+1))
end

function Drummer:enable()
  if self.pattern==nil then 
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
  local id=self.id
  if id==nil then
    print("NIL!?!?!")
    id=1
  end
  if self.pattern(beat) then
    engine.nanotonic(
      params:get(id.."distAmt"),
      params:get(id.."eQFreq"),
      params:get(id.."eQGain"),
      params:get(id.."level"),
      params:get(id.."mix"),
      params:get(id.."modAmt"),
      params:get(id.."modMode"),
      params:get(id.."modRate"),
      params:get(id.."nEnvAtk"),
      params:get(id.."nEnvDcy"),
      params:get(id.."nEnvMod"),
      params:get(id.."nFilFrq"),
      params:get(id.."nFilMod"),
      params:get(id.."nFilQ"),
      params:get(id.."nStereo"),
      params:get(id.."oscAtk"),
      params:get(id.."oscDcy"),
      params:get(id.."oscFreq"),
      params:get(id.."oscWave"),
      params:get(id.."oscVel"),
      params:get(id.."nVel"),
      params:get(id.."modVel"),
      id
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