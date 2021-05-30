local Patterns={}

function Patterns:debug(s)
  if mode_debug then
    print("patterns: "..s)
  end
end


function Patterns:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  return o
end

function Patterns:random(density_min,density_max)
  if density_min==nil then
    density_min=0
  end
  if density_max==nil then 
    density_max=1
  end
  local density=-1
  local pattern_string=""
  while density<density_min or density>density_max do
    pattern_string = os.capture("shuf -n1 /home/we/dust/code/supertonic/data/patterns.json")
    num_xs=0
    num_dashes=0
    for c in pattern_string:gmatch"." do
      if c=="-" then
        num_dashes = num_dashes + 1
      elseif c=="x" then
        num_xs=num_xs+1
      end
    end
    density = num_xs / (num_xs+num_dashes)
  end
  local p = json.decode(pattern_string)
  for k,v in pairs(p) do
    self:debug(k..": "..v)
  end
  return p
end

return Patterns