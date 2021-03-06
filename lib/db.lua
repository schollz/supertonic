local DB={}


function DB:debug(s)
  if mode_debug then
    print("db: "..s)
  end
end


function DB:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  o.last_pattern=nil
  return o
end


function DB:pattern_to_num(pattern_string)
  local shash=0
  local i=0
  for c in pattern_string:gmatch"." do
    if c=='x' then
      shash=shash+(2^i)
    end
    i=i+1
  end
  shash=math.floor(shash)
  return shash
end

function DB:num_to_pattern(shash)
  local re={}
  while shash>0 do
    table.insert(re,shash%2==0 and"-" or "x")
    shash=math.floor(shash/2)
  end
  while #re<16 do
    table.insert(re,"-")
  end
  return table.concat(re,"")
end

-- assert(pattern_to_num("--x---x---x---x---x---x---x---x-")==1145324612,"BAD HASH")
-- assert(pattern_to_num("--x---x---x---x---x---x---x---xx")==3292808260,"BAD HASH")
-- assert(num_to_pattern(pattern_to_num("x---x---x---x---"))=="x---x---x---x---","BAD NUM")
-- assert(num_to_pattern(pattern_to_num("xxxxxxxxxxxxxxxx"))=="xxxxxxxxxxxxxxxx","BAD NUM")


function DB:db_sql_weighted_(query)
  local cmd=string.format('sqlite3 /home/we/dust/data/supertonic/drum_ai_patterns.db "%s"',query)
  print(cmd)
  local result=os.capture(cmd)
  print(result)
  local pids={}
  local weights={}
  local total_weight=0
  for line in result:gmatch("%S+") do
    foo=string.split(line,"|")
    pid=tonumber(foo[1])
    weight=math.floor(tonumber(foo[2]))
    table.insert(weights,weight)
    table.insert(pids,pid)
    total_weight=total_weight+weight
  end
  if total_weight==0 then
    print("no results")
    do return end
  end
  --print("found "..#pids.." results")
  local randweight=math.random(0,total_weight-1)
  local pid_new=pids[1]
  for i,w in ipairs(weights) do
    if randweight<w then
      pid_new=pids[i]
      break
    end
    randweight=randweight-w
  end
  return pid_new
end

function DB:adj(ins,pid_base,not_pid)
  return self:like(ins,ins,pid_base,not_pid)
end

function DB:random(ins)
  math.randomseed(clock.get_beats())
  do return common_pattern[ins][math.random(1,100)] end

  if not_pid==nil then 
    not_pid=self.last_pattern
  end
  local rr=math.random(1,65000)
  local query=string.format([[SELECT DISTINCT pidbase FROM prob INDEXED BY idx_inspid WHERE ins1==%d AND pidbase>0 AND pidbase<5000 ORDER BY RANDOM() LIMIT 1]],ins)
  print(query)
  local cmd=string.format('sqlite3 /home/we/dust/data/supertonic/drum_ai_patterns.db "%s"',query)
  local result=os.capture(cmd)
  return tonumber(result)
end

function DB:like(ins,ins_base,pid_base,not_pid)
  if not_pid==nil then 
    not_pid=self.last_pattern
  end
  if ins==ins_base then
    return self:random(ins)
  else
    local query=string.format([[SELECT pid,prob*100000 FROM prob INDEXED BY idx_inspid WHERE ins1==%d AND pidbase==%d AND ins2==%d AND pid!=%d]],ins_base,pid_base,ins,not_pid==nil and-1 or not_pid)
    print(query)
    self.last_pattern=self:db_sql_weighted_(query)
    return self.last_pattern
  end
end

return DB