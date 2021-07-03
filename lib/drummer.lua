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
  o.enabled=false
  o.id=o.id
  o.name=o.name 
  o.update=true
  o.patch={}
  for _,v in ipairs({"distAmt","eQFreq","eQGain","level","mix","modAmt","modMode","modRate","nEnvAtk","nEnvDcy","nEnvMod","nFilFrq","nFilMod","nFilQ","nStereo","oscAtk","oscDcy","oscFreq","oscWave","oscVel","nVel","modVel"}) do
    o.patch[v]=0
  end
  print(o.patch)
  return o
end

function Drummer:set_patch(num,patch)
  for k,v in pairs(patch) do
    if k~="name" then
      params:set(self.id..num..k,v)
    end
  end
end

function Drummer:set_pattern(pattern_string)
  params:set(self.id.."pattern",pattern_string)
  self.pattern_string=pattern_string
  self.pattern=self:xox(pattern_string)
end

function Drummer:toggle_pattern(pos,on)
  local current="-"
  if on==true then 
    current="+"
  end
  if on==nil then 
    current=self.pattern_string:sub(pos,pos)
    if current=="-" then
      current="x"
    else
      current="-"
    end
  end
  pos=math.floor(pos)
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

function Drummer:update_patch()
  for k,_ in pairs(self.patch) do 
    self.patch[k]=util.linlin(0,1,params:get(self.id.."1"..k),params:get(self.id.."2"..k),params:get(self.id.."morph"))
  end
  -- binary parameters
  local v=(params:get(self.id.."morph")>0.5) and 2 or 1
  for _,k in ipairs({"oscWave","modMode","nFilMod","nEnvMod","nStereo"}) do
    self.patch[k]=params:get(self.id..v..k)
  end  
  self.update=false
end

function Drummer:update_patch_manually(patch)
  self.patch=patch
  for k,v in pairs(self.patch) do
    self.patch[k]=v
  end
end

function Drummer:hit()
  engine.supertonic(
    self.patch["distAmt"],
    self.patch["eQFreq"],
    self.patch["eQGain"],
    self.patch["level"],
    self.patch["mix"],
    self.patch["modAmt"],
    self.patch["modMode"],
    self.patch["modRate"],
    self.patch["nEnvAtk"],
    self.patch["nEnvDcy"],
    self.patch["nEnvMod"],
    self.patch["nFilFrq"],
    self.patch["nFilMod"],
    self.patch["nFilQ"],
    self.patch["nStereo"],
    self.patch["oscAtk"],
    self.patch["oscDcy"],
    self.patch["oscFreq"],
    self.patch["oscWave"],
    self.patch["oscVel"],
    self.patch["nVel"],
    self.patch["modVel"],
    20000,
    1,
    self.id
  )
end
function Drummer:step(beat)
  if not self.enabled then 
    do return false end
  end
  if self.update then 
    self:update_patch()
  end
  local id=self.id
  if id==nil then
    print("NIL!?!?!")
    id=1
  end
  if self.pattern(beat) then
    engine.supertonic(
      self.patch["distAmt"],
      self.patch["eQFreq"],
      self.patch["eQGain"],
      self.patch["level"],
      self.patch["mix"],
      self.patch["modAmt"],
      self.patch["modMode"],
      self.patch["modRate"],
      self.patch["nEnvAtk"],
      self.patch["nEnvDcy"],
      self.patch["nEnvMod"],
      self.patch["nFilFrq"],
      self.patch["nFilMod"],
      self.patch["nFilQ"],
      self.patch["nStereo"],
      self.patch["oscAtk"],
      self.patch["oscDcy"],
      self.patch["oscFreq"],
      self.patch["oscWave"],
      self.patch["oscVel"],
      self.patch["nVel"],
      self.patch["modVel"],
      params:get("global lpf freq"),
      params:get("global lpf rq"),
      id
    )
    if self.id<5 then
      clock.run(function()
        crow.output[self.id].volts=5
        clock.sync(1/8-1/16)
        crow.output[self.id].volts=0
      end)
    end
  end
  return true
end

-- function Drummer:random_patch()
--   for _, p in ipairs(menu__.parameters_morph) do
--     params:set(params:get("selected")..params:get("patch")..p.id,util.linlin(0,1,p.range[1],p.range[2],math.random()))
--   end
-- end

function Drummer:xox(riddim)
  -- return riddim detector
  -- beat starts on 1
  return function (beat)
    beat = ((beat-1) % #riddim) + 1
    return riddim:sub(beat, beat) ~= '-'
  end
end


return Drummer
