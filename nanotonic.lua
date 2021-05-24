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
drummer_number=3
drummer_density={0,1}

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

  -- initialize drummers
  for i=1,drummer_number do 
    drummer[i]=drummer_:new({name=""..i,id=i})
  end

  -- after initializing operators, intialize time keeper
  timekeeper:init()

  -- init dev
  dev_:new()

  startup_done=true
end

function updater(c)
  if not startup_initiated then
    print("starting up")
    clock.run(startup)
  end
end

function enc(k,d)
  if k>1 then
    drummer_density[k-1]=drummer_density[k-1]+d/50
    drummer_density[k-1]=util.clamp(drummer_density[k-1],0,1)
    redraw()
  end
end

function key(k,z)
  if z==1 then
    local dp=drum_pattern:random(drummer_density[1],drummer_density[2])
    drummer[1]:set_pattern(dp["kick"])
    drummer[2]:set_pattern(dp["sd"])
    drummer[3]:set_pattern(dp["ch"])
    redraw()
  end
end


function redraw()
  screen.clear()
  screen.move(32,8)
  screen.text_center(drummer_density[1].."-"..drummer_density[2])
  for i=1,drummer_number do 
    screen.move(0,8+(i*12))
    screen.text(drummer[i].pattern_string)
  end
  screen.update()
end

