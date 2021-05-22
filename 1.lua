function lines_from(file)
  lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

function trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local file = 'microtonic.preset'
local lines = lines_from(file)

drum_patches=false
local patches={}
i=0
for _,line in ipairs(lines) do
	line=trim(line)
	-- print(line)
	if string.find(line,"DrumPatches") then
		drum_patches=true
	end
	if drum_patches then
		if line:find("Name")==1 then
			i=i+1
			patches[i]={}
			patches[i].name=line
		elseif line:find("OscWave")==1 then
			patches[i].oscWaveSine=0
			patches[i].oscWaveTriangle=0
			patches[i].oscWaveRamp=0
			if string.find(line,"Sine") then
				patches[i].oscWaveSine=1
			elseif string.find(line,"Triangle") then
				patches[i].oscWaveTriangle=1
			elseif string.find(line,"TODO") then
				patches[i].oscWaveRamp=1
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
			patches[i].modModeDecay=0
			patches[i].modModeSine=0
			patches[i].modModeNoise=0
			if string.find(line,"Decay") then
				patches[i].modModeDecay=1
			elseif string.find(line,"Sine") then
				patches[i].modModeSine=1
			elseif string.find(line,"Noise") then
				patches[i].modModeNoise=1
			end
		elseif line:find("ModRate")==1 then
			local val=0
			for num in string.gmatch( line, "[0-9]+%.[0-9]+" ) do
				val=tonumber(num)
			end
			patches[i].modRate=val
			if string.find(line,"Hz") then
				patches[i].modRate=1/val
			end
		elseif line:find("ModAmt")==1 then
			local val=0
			for num in string.gmatch( line, "[0-9]+%.[0-9]+" ) do
				val=tonumber(num)
			end
			patches[i].modAmt=val
		elseif line:find("NFilMod")==1 then
			patches[i].nFilModLP=0
			patches[i].nFilModBP=0
			patches[i].nFilModHP=0
			if string.find(line,"LP") then
				patches[i].nFilModLP=1
			elseif string.find(line,"BP") then
				patches[i].nFilModBP=1
			elseif string.find(line,"HP") then
				patches[i].nFilModHP=1
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
			patches[i].nEnvModExp=0
			patches[i].nEnvModMod=0
			patches[i].nEnvModLinear=0
			if string.find(line,"Exp") then
				patches[i].nEnvModExp=1
			elseif string.find(line,'"Mod"') then
				patches[i].nEnvModMod=1
			elseif string.find(line,"Linear") then
				patches[i].nEnvModLinear=1
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
		elseif line:find("EQGain")==1 then
			local val=0
			for num in string.gmatch( line, "[0-9]+%.[0-9]+" ) do
				val=tonumber(num)
			end
			patches[i].eQGain=val
		elseif line:find("Level")==1 then
			local val=0
			for num in string.gmatch( line, "[0-9]+%.[0-9]+" ) do
				val=tonumber(num)
			end
			patches[i].level=val
		end
	end
end

for _,p in ipairs(patches) do
	print("// "..p.name)
	print("(")
	print('Synth("nanotonic",[')
	keys={}
	for k,v in pairs(p) do
		table.insert(keys,k)
	end
	table.sort(keys)
	for _,k in ipairs(keys) do
		local v=p[k]
		if k=="name" then
		else
			print("\\"..k..","..v..",")
		end
	end
	print("]);")
	print(")")
end