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
  drummer[1]:set_pattern(dp["kick"])
  drummer[2]:set_pattern(dp["sd"])
  drummer[3]:set_pattern(dp["ch"])
  local patches=nanotonic_patches:load("/home/we/dust/code/nanotonic/data/po-32_drum_bot_l4.mtpreset")
  for i=1,3 do 
    drummer[i]:set_patch(patches[i])
  end

  for i=1,3 do 
    drummer[i]:enable()
  end
  timekeeper:start()

  return o
end

return Dev