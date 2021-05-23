-- thirtythree v0.1.0
--
-- po-33 for the norns+grid


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
drummers={} -- drummers
drummer_number=3

-- engine
engine.name="Nanotonic"

-- individual libraries
lattice=include("thirtythree/lib/lattice")
timekeeper_=include("lib/timekeeper")
timekeeper=timekeeper_:new()
drummer_=include("lib/drummer")
dev_=include("lib/dev")

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
    drummers[i]=drummer_:new({name:""..i})
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
end

function key(k,z)
end


function redraw()
  screen.clear()

  screen.update()
end

