-- thirtythree v0.1.0
--
--


mode_debug=true

--json
print(_VERSION)
print(package.cpath)
if not string.find(package.cpath,"/home/we/dust/code/nanotonic/lib/") then
  package.cpath=package.cpath..";/home/we/dust/code/nanotonic/lib/?.so"
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
engine.name="Nanotonic"

-- individual libraries
lattice=include("thirtythree/lib/lattice")
timekeeper_=include("lib/timekeeper")
timekeeper=timekeeper_:new()
drummer_=include("lib/drummer")
dev_=include("lib/dev")
patterns_=include("lib/patterns")
drum_pattern=patterns_:new()
patches_=include("lib/patches")
nanotonic_patches=patches_:new()
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
  if update_screen then
    redraw()
  end
end

function enc(k,d)
  if current_page==1 then
    if k==2 then 
      params:delta("selected",sign(d))
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
      local pattern_string=params:get(params:get("selected").."pattern")
        local pid1=db_pattern:pattern_to_num(pattern_string:sub(1,16))
        local pid2=db_pattern:pattern_to_num(pattern_string:sub(17))
        print(pid1,pid2)
        local pid1new=db_pattern:like(params:get("selected"),1,pid1)
        local pid2new=db_pattern:like(params:get("selected"),1,pid2)
        if pid1new ~= nil and pid2new~=nil then
          pattern_string=db_pattern:num_to_pattern(pid1new)..db_pattern:num_to_pattern(pid2new)
          drummer[params:get("selected")]:set_pattern(pattern_string)
        end
      else
        drummer[params:get("selected")]:toggle_pattern(current_pos)
      end
    elseif k==2 and z==1 then
      local pattern_string=params:get(params:get("selected").."pattern")
      local pid1=db_pattern:pattern_to_num(pattern_string:sub(1,16))
      local pid2=db_pattern:adj(params:get("selected"),pid1)
      if pid2~=nil then 
        drummer[params:get("selected")]:set_pattern(pattern_string:sub(1,16)..db_pattern:num_to_pattern(pid2))
      end
    end
  end
  update_screen=true
end


function redraw()
  if not startup_done then 
    do return end 
  end
  screen.clear()

  -- draw tracks
  for i=1,drummer_number do 
    if params:get("selected")==i then 
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

