local Timekeeper={}

function Timekeeper:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  return o
end

function Timekeeper:init()
  self.lattice=lattice:new({
    ppqn=64
  })

  self.confettis={4,8,16,24}
  self.next=8
  self.step=1
  self.pattern={}
  for i=1,drummer_number do
    self.pattern[i]=self.lattice:new_pattern{
      action=function(t)
        if i==1 then 
          self.step=(t/16+1)%32+1
        end
        if i==1 and (t/16+1)%self.next==0 then 
          self.next=self.confettis[math.random(#self.confettis)]
          reset_confetti()
        end
        drummer[i]:step(t/16+1)
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
  self.lattice:hard_restart()
end

return Timekeeper
