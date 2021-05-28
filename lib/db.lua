TEMP_DIR="/tmp/"
RANDOMSEED="1284553781927398174017240"

local charset={} do -- [0-9a-zA-Z]
  for c=48,57 do table.insert(charset,string.char(c)) end
  for c=65,90 do table.insert(charset,string.char(c)) end
  for c=97,122 do table.insert(charset,string.char(c)) end
end

local function random_string(length)
  if not length or length<=0 then return '' end
  return random_string(length-1)..charset[math.random(1,#charset)]
end

local function generate_seed()
  RANDOMSEED=""
  for i=1,10 do
    RANDOMSEED=RANDOMSEED..math.random(1,10)
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

function pattern_to_num(pattern_string)
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

function num_to_pattern(shash)
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

assert(pattern_to_num("--x---x---x---x---x---x---x---x-")==1145324612,"BAD HASH")
assert(pattern_to_num("--x---x---x---x---x---x---x---xx")==3292808260,"BAD HASH")
assert(num_to_pattern(pattern_to_num("x---x---x---x---"))=="x---x---x---x---","BAD NUM")
assert(num_to_pattern(pattern_to_num("xxxxxxxxxxxxxxxx"))=="xxxxxxxxxxxxxxxx","BAD NUM")


function string.split(s,sep)
  local fields={}

  local sep=sep or " "
  local pattern=string.format("([^%s]+)",sep)
  string.gsub(s,pattern,function(c) fields[#fields+1]=c end)

  return fields
end


function db_sql_weighted_(query)
  local result=os.capture(string.format('sqlite3 db.db "%s"',query))
  local pids={}
  local weights={}
  local total_weight=0
  for line in result:gmatch("%S+") do
    foo=string.split(line,"|")
    pid=tonumber(foo[1])
    weight=tonumber(foo[2])
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

function db_pattern_adj(ins,pid_base,not_pid)
  local query=string.format([[SELECT pid,count(pid) FROM drum INDEXED BY idx_pidadj WHERE ins==%d AND pidadj==%d AND pid!=%d GROUP BY pid ORDER BY count(pid) DESC LIMIT 100]],ins,pid_base,not_pid==nil and-1 or not_pid)
  return db_sql_weighted_(query)
end

function db_pattern_like(ins,ins_base,pid_base,not_pid)
  local query=string.format([[SELECT pid,count(pid) FROM drum INDEXED BY idx_gid WHERE gid in (SELECT gid FROM drum INDEXED BY idx_pid WHERE ins==%d AND pid==%d) AND ins==%d AND pid!=%d GROUP BY pid ORDER BY count(pid) DESC LIMIT 100]],ins_base,pid_base,ins,not_pid==nil and-1 or not_pid)
  return db_sql_weighted_(query)
end


math.randomseed(os.time())
print("RESULTS")
local pp="x---x---x-----x-"
print(pp)
local pid=nil
for i=1,3 do
  pid1=db_pattern_like(2,1,pattern_to_num(pp),pid1)
  print(num_to_pattern(pid1))
end
print("ADJ")
pp="x---x---x---x---"
local pid=nil
for i=1,10 do
  pid1=db_pattern_adj(5,pattern_to_num(pp),pid1)
  print(num_to_pattern(pid1))
end
