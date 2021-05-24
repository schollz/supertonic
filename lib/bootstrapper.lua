json = require "json"

function xox(riddim)
  -- return riddim detector
  -- beat starts on 1
  return function (beat)
    beat = ((beat-1) % #riddim) + 1
    return riddim:sub(beat, beat) ~= '-'
  end
end

function os.capture(cmd,raw)
  local f=assert(io.popen(cmd,'r'))
  local s=assert(f:read('*a'))
  f:close()
  if raw then return s end
  s=string.gsub(s,'^%s+','')
  s=string.gsub(s,'%s+$','')
  s=string.gsub(s,'[\n\r]+',' ')
  return s
end

function pattern_random(density_min,density_max)
	if density_min==nil then
		density_min=0
	end
	if density_max==nil then 
		density_max=1
	end
	local density=-1
	local pattern_string=""
	while density<density_min or density>density_max do
		pattern_string = os.capture("shuf -n1 ../data/patterns.json")
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
		print(k,v)
	end
	return p
end

pattern_random(0,0.2)

part=xox("x---x-----x-")
for i=1,16 do 
	print(i,part(i))
end

patchloader=require("patches")
patches=patchloader:load("../data/po-32_drum_bot_l4.mtpreset")

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


for _,p in ipairs(patches) do
	print('engine.nanotonic=(')
	keys={}
	for k,v in pairs(p) do
		table.insert(keys,k)
	end
	table.sort(keys)
	for _,k in ipairs(keys) do
		local v=p[k]
		if k=="name" then
		else
			print("self.patch."..k..",")
		end
	end
	print(")")
	break
end

for _,p in ipairs(patches) do
	keys={}
	for k,v in pairs(p) do
		table.insert(keys,k)
	end
	table.sort(keys)
	for i,k in ipairs(keys) do
		local v=p[k]
		if k=="name" then
		else
			print("\\"..k..", msg["..i.."],")
		end
	end
	break
end