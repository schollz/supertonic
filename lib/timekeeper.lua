local Timekeeper={}

function Timekeeper:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  return o
end

function Timekeeper:init()
  self.ppqn=16
  self.lattice=lattice:new({
    ppqn=self.ppqn
  })

  self.playing=true
  self.confettis={4,8,16,24,32,48}
  self.next=8
  self.step=1
  self.pattern={}
  self.last_step={}
  for i=1,drummer_number do
    self.last_step[i]=-1
    self.pattern[i]=self.lattice:new_pattern{
      action=function(t)
        if i==1 and (t/(self.ppqn/4)+1)%self.next==0 then 
          self.next=self.confettis[math.random(#self.confettis)]
          reset_confetti()
        end
        if i==1 and self.playing then 
          self.step=(t/(self.ppqn/4)+1)%32+1
        end
        local next_step=util.round(t/(self.ppqn/4)+1)
        if self.playing then
          drummer[i]:step(next_step)
          self.last_step[i]=next_step
        end
      end,
      division=1/16
    }
  end

  self.lattice:start()
end

function Timekeeper:set_swing(i,s)
  self.pattern[i]:set_swing(s)
end


function Timekeeper:get_swing(i)
  return self.pattern[i].swing
end

function Timekeeper:start()
  print("starting")
  for i=1,drummer_number do
    self.last_step[i]=-1
  end
  self.playing=true
  self.lattice:hard_restart()
end

function Timekeeper:stop()
  self.playing=false
  self.step=1
end

function Timekeeper:toggle()
  if self.playing then 
    self:stop()
  else
    self:start()
  end
end
return Timekeeper
