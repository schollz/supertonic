-- supermicro v0.0.0
--
--

include('lib/p8')
mode_debug=true

--json
print(_VERSION)
print(package.cpath)
if not string.find(package.cpath,"/home/we/dust/code/supermicro/lib/") then
  package.cpath=package.cpath..";/home/we/dust/code/supermicro/lib/?.so"
end
json=require("cjson")

-- globals
include("lib/utils")
-- global state
drummer={} -- drummers
drummer_number=5
drummer_density={0,1}
shift=false
k3=false
update_screen=false
current_page=1
current_pos=1

-- engine
engine.name="Supermicro"

-- individual libraries
lattice=include("thirtythree/lib/lattice")
timekeeper_=include("lib/timekeeper")
timekeeper=timekeeper_:new()
drummer_=include("lib/drummer")
dev_=include("lib/dev")
patterns_=include("lib/patterns")
drum_pattern=patterns_:new()
patches_=include("lib/patches")
supermicro_patches=patches_:new()
menu_=include("lib/menu")
menu__=menu_:new()
db_=include("lib/db")
db_pattern=db_:new()

function init()
  -- start updater
  runner=metro.init()
  runner.time=1/15
  runner.count=-1
  runner.event=updater
  runner:start()
  startup_done=false
  startup_initiated=false
end

function startup()
  startup_initiated=true

  -- initialize menu
  menu__:init()

  -- initialize drummers
  for i=1,drummer_number do 
    drummer[i]=drummer_:new({name=""..i,id=i})
  end

  -- after initializing operators, intialize time keeper
  timekeeper:init()

  -- init dev
  dev_:new()

  startup_done=true
  redraw()
end

function updater(c)
  if not startup_initiated then
    print("starting up")
    startup()
  end
  redraw()
end

function enc(k,d)
  if current_page==1 then
    if k==2 then 
      if shift then
        params:delta(params:get("selected").."basis",sign(d))
      else
        params:delta("selected",sign(d))
      end
    elseif k==3 then
      current_pos = current_pos + sign(d)
      if current_pos > 32 then 
        current_pos=1
      elseif current_pos < 1 then 
        current_pos = 32
      end
    end
    if k3 then
      drummer[params:get("selected")]:toggle_pattern(current_pos)
    end
  end
  update_screen=true
end

function key(k,z)
  if k==1 then 
    shift=z==1
  elseif k==3 then
    k3=z==1
  end
  if current_page==1 then
    if k==3 and z==1 then
      if shift then 
        local insbase=math.floor(params:get(params:get("selected").."basis"))
        local pattern_string_base=params:get(insbase.."pattern")
        local pid1=db_pattern:pattern_to_num(pattern_string_base:sub(1,16))
        local pid2=db_pattern:pattern_to_num(pattern_string_base:sub(17))
        print(pattern_string_base:sub(1,16),pid1)
        print(pattern_string_base:sub(17),pid2)
        local pid1new=db_pattern:like(params:get("selected"),insbase,pid1)
        local pid2new=db_pattern:like(params:get("selected"),insbase,pid2)
        print(pid1new,pid2new)
        if pid1new ~= nil and pid2new~=nil then
          local pattern_string=db_pattern:num_to_pattern(pid1new)..db_pattern:num_to_pattern(pid2new)
          drummer[params:get("selected")]:set_pattern(pattern_string)
        end
      else
        drummer[params:get("selected")]:toggle_pattern(current_pos)
      end
    elseif k==2 and z==1 then
      if shift then
        local pattern_string=params:get(params:get("selected").."pattern")
        local pid1=db_pattern:pattern_to_num(pattern_string:sub(1,16))
        local pid2=db_pattern:adj(params:get("selected"),pid1)
        if pid2~=nil then 
          drummer[params:get("selected")]:set_pattern(pattern_string:sub(1,16)..db_pattern:num_to_pattern(pid2))
        end
      end
    end
  end
  update_screen=true
end

p8p=0
p8q=0
p8s=0
p8r=rnd
p8b=p8r()
function reset_confetti()
    srand(t())
    p8b=p8r()
    p8s=16
end

function redraw()
  if not startup_done then 
    do return end 
  end
  screen.clear()

  p8s=p8s*.9
  local k=p8s*cos(p8b)
  local l=p8s*sin(p8b)
  p8p=p8p+k
  p8q=p8q+l
  srand()
  for d=1,10,.1 do
    local x=(p8r(146)+p8p*d/8)%146-9
    local y=(p8r(146)+p8q*d/8)%146-9
    local a=d+t()*(1+p8r())/2
    local u=d*cos(a)
    local v=d*sin(a)
    line(x-u,y-v,x+k,y+l,d)
    line(x+u,y+v)
  end
  screen.level(0)
  screen.rect(0,20,128,64)
  screen.fill()

  if shift then
    -- show basis
    local i=math.floor(params:get(params:get("selected").."basis"))
    screen.level(4)
    screen.rect(0,10+(i*9),128,8)
    screen.fill()
  end
  -- draw tracks
  for i=1,drummer_number do 
    if shift and i==math.floor(params:get(params:get("selected").."basis")) then
      screen.level(0)
    elseif params:get("selected")==i then 
      screen.level(15)
    else
      screen.level(4)
    end
    screen.move(0,16+(i*9))
    screen.text(params:get(i.."pattern"))
  end
  -- draw current position
  screen.move((current_pos-1)*4,19+(params:get("selected")*9))
  screen.level(15)
  screen.line_rel(3,0)
  screen.stroke()
  screen.update()
end
