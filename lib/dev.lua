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


  return o
end

return Dev