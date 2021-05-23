local Dev={}

function Dev:debug(s)
  if mode_debug then
    print("part: "..s)
  end
end


function Dev:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self

  -- do dev stuff
  local dp=drum_pattern:random(0.2,0.4)
  drummers[1].set_pattern(dp["kick"])
  drummers[2].set_pattern(dp["sd"])
  drummers[3].set_pattern(dp["ch"])
  local patches=nanotonic_patches:load("/home/we/dust/data/nanotonic/data/microtonic.preset")
  for i=1,3 do 
    drummers[i].set_patch(patches[i])
  end
  
  return o
end

return Dev