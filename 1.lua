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
patch={}
for i,line in ipairs(lines) do
	line=trim(line)
	-- print(line)
	if string.find(line,"DrumPatches") then
		drum_patches=true
	end
	if drum_patches then
		if line:find("Name")==1 then
			patch.name=line
			print(patch.name)
		elseif line:find("OscFreq")==1 then
			local val=0
			for num in string.gmatch( line, "[0-9]+%.[0-9]+" ) do
				val=tonumber(num)
			end
			print(val)
			for chunk in string.gmatch(line, '"(.-)"') do print(chunk) end
		end
	end
end
