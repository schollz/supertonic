local Timekeeper={}

function Timekeeper:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  return o
end

function Timekeeper:init()
  self.lattice=lattice:new({
    ppqn=16
  })

  self.playing=true
  self.confettis={4,8,16,24,32,48}
  self.next=8
  self.step=1
  self.pattern={}
  for i=1,drummer_number do
    self.pattern[i]=self.lattice:new_pattern{
      action=function(t)
        if i==1 and (t/4+1)%self.next==0 then 
          self.next=self.confettis[math.random(#self.confettis)]
          reset_confetti()
        end
        if i==1 and self.playing then 
          self.step=(t/4+1)%32+1
        end
        if self.playing then
          drummer[i]:step(t/4+1)
        end
      end,
      division=1/16
    }
  end

  self.lattice:start()
end


function Timekeeper:get_swing(i)
  return self.pattern[i].swing
end

function Timekeeper:start()
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
