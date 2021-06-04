local Patches={}

function Patches:debug(s)
  if mode_debug then
    print("part: "..s)
  end
end


function Patches:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  return o
end


function Patches:lines_from(file)
  lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

function Patches:trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function Patches:load(preset_file)
  local lines = self:lines_from(preset_file)

  drum_patches=false
  local patches={}
  local i=0
  for _,line in ipairs(lines) do
    line=self:trim(line)
    if string.find(line,"DrumPatches") then
      drum_patches=true
    elseif string.find(line,"Patterns:") then
      drum_patches=false
    elseif drum_patches then
      if string.sub(line,-1)=="{" then
        i=i+1
        patches[i]={}
        patches[i].name=line
      elseif line:find("OscWave")==1 then
        patches[i].oscWave=0
        if string.find(line,"Triangle") then
          patches[i].oscWave=1
        elseif string.find(line,"Saw") then
          patches[i].oscWave=2
        end
      elseif line:find("OscFreq")==1 then
        local val=0
        for num in string.gmatch( line, "[0-9]+%.[0-9]+" ) do
          val=tonumber(num)
        end
        patches[i].oscFreq=val
      elseif line:find("OscAtk")==1 then
        local val=0
        for num in string.gmatch( line, "[0-9]+%.[0-9]+" ) do
          val=tonumber(num)
        end
        patches[i].oscAtk=val
      elseif line:find("OscDcy")==1 then
        local val=0
        for num in string.gmatch( line, "[0-9]+%.[0-9]+" ) do
          val=tonumber(num)
        end
        patches[i].oscDcy=val
      elseif line:find("ModMode")==1 then
        patches[i].modMode=0
        if string.find(line,"Decay") then
          patches[i].modMode=0
        elseif string.find(line,"Sine") then
          patches[i].modMode=1
        elseif string.find(line,"Noise") then
          patches[i].modMode=2
        end
      elseif line:find("ModRate")==1 then
        local val=0
        for num in string.gmatch( line, "[0-9]+%.[0-9]+" ) do
          val=tonumber(num)
        end
        if string.find(line,"Hz") then
          patches[i].modRate=val
        else
          patches[i].modRate=1000/val
        end
      elseif line:find("ModAmt")==1 then
        local val=0
        for num in string.gmatch( line, "[0-9]+%.[0-9]+" ) do
          val=tonumber(num)
        end
        if string.find(line,"-") then 
          val = val * -1
        end
        patches[i].modAmt=val
      elseif line:find("NFilMod")==1 then
        patches[i].nFilMod=0
        if string.find(line,"LP") then
          patches[i].nFilMod=0
        elseif string.find(line,"BP") then
          patches[i].nFilMod=1
        elseif string.find(line,"HP") then
          patches[i].nFilMod=2
        end
      elseif line:find("NFilFrq")==1 then
        local val=0
        for num in string.gmatch( line, "[0-9]+%.[0-9]+" ) do
          val=tonumber(num)
        end
        patches[i].nFilFrq=val
      elseif line:find("NFilQ")==1 then
        local val=0
        for num in string.gmatch( line, "[0-9]+%.[0-9]+" ) do
          val=tonumber(num)
        end
        patches[i].nFilQ=val
      elseif line:find("NStereo")==1 then
        patches[i].nStereo=1
        if string.find(line,"Off") then
          patches[i].nStereo=0
        end
      elseif line:find("NEnvMod")==1 then
        patches[i].nEnvMod=0
        if string.find(line,"Exp") then
          patches[i].nEnvMod=0
        elseif string.find(line,"Linear") then
          patches[i].nEnvMod=1
        elseif string.find(line,'"Mod"') or string.find(line,': Mod') then
          patches[i].nEnvMod=2
        end
      elseif line:find("NEnvAtk")==1 then
        local val=0
        for num in string.gmatch( line, "[0-9]+%.[0-9]+" ) do
          val=tonumber(num)
        end
        patches[i].nEnvAtk=val
      elseif line:find("NEnvDcy")==1 then
        local val=0
        for num in string.gmatch( line, "[0-9]+%.[0-9]+" ) do
          val=tonumber(num)
        end
        patches[i].nEnvDcy=val
      elseif line:find("Mix")==1 then
        local val=0
        for num in string.gmatch( line, "[0-9]+%.[0-9]+" ) do
          val=tonumber(num)
          break
        end
        patches[i].mix=val
      elseif line:find("DistAmt")==1 then
        local val=0
        for num in string.gmatch( line, "[0-9]+%.[0-9]+" ) do
          val=tonumber(num)
        end
        patches[i].distAmt=val
      elseif line:find("EQFreq")==1 then
        local val=0
        for num in string.gmatch( line, "[0-9]+%.[0-9]+" ) do
          val=tonumber(num)
        end
        patches[i].eQFreq=val
      elseif line:find("OscVel")==1 then
        local val=0
        for num in string.gmatch( line, "[0-9]+%.[0-9]+" ) do
          val=tonumber(num)
        end
        patches[i].oscVel=val
      elseif line:find("NVel")==1 then
        local val=0
        for num in string.gmatch( line, "[0-9]+%.[0-9]+" ) do
          val=tonumber(num)
        end
        patches[i].nVel=val
      elseif line:find("ModVel")==1 then
        local val=0
        for num in string.gmatch( line, "[0-9]+%.[0-9]+" ) do
          val=tonumber(num)
        end
        patches[i].modVel=val
      elseif line:find("EQGain")==1 then
        local val=0
        for num in string.gmatch( line, "[0-9]+%.[0-9]+" ) do
          val=tonumber(num)
        end
        if string.find(line,"-") then 
          val = val * -1
        end
        patches[i].eQGain=val
      elseif line:find("Level")==1 then
        local val=0
        for num in string.gmatch( line, "[0-9]+%.[0-9]+" ) do
          val=tonumber(num)
        end
        if string.find(line,"-") then 
          val = val * -1
        end
        patches[i].level=val
      end
    end
  end
  for i,p in ipairs(patches) do
    print(p.name,p.oscAtk,p.oscDcy)
  end
  return patches
end

return Patches