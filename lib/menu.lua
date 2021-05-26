local Menu={}
local Formatters=require 'formatters'

function Menu:debug(s)
  if mode_debug then
    print("part: "..s)
  end
end


function Menu:new(o)
  o=o or {}
  setmetatable(o,self)
  self.__index=self
  return o
end


function Menu:rebuild_menu(v)
  for _,param_name in ipairs(self.param_names) do
    for i=1,drummer_number do
      if i==v then
        params:show(i..param_name)
      else
        params:hide(i..param_name)
      end
    end
  end
end

function Menu:init()
  -- setup parameters
    -- \distAmt,34.064063429832,
    -- \eQFreq,80.661909666463,
    -- \eQGain,30.246815681458,
    -- \level,-20.120152232229,
    -- \mix,88.153877258301,
    -- \modAmt,33.019509360458,
    -- \modMode,0,
    -- \modRate,246.77166176396,
    -- \nEnvAtk,2.1977363693469,
    -- \nEnvDcy,1104.977660676,
    -- \nEnvMod,0,
    -- \nFilFrq,392.00617432122,
    -- \nFilMod,0,
    -- \nFilQ,1.463421337541,
    -- \nStereo,1,
    -- \oscAtk,0,
    -- \oscDcy,726.5732892423,
    -- \oscFreq,48.060961337325,
    -- \oscWave,0,
  self.parameters={
    {id="level",name="level",range={-100,10},default=0,unit='dB'},
    {id="distAmt",name="distortion",range={0,100},default=0,unit=''},
    {id="eQFreq",name="eq freq",range={20,20000},default=1000,freq=true},
    {id="eQGain",name="eq gain",range={-40,40},default=0,unit='dB'},
    {id="mix",name="mix",range={0,100},default=50,unit='',increment=1,formatter=function(v) 
      return math.floor(v.raw*100).."% tone, "..math.floor((1-v.raw)*100).."% noise"
    end},
    {id="oscWave",name="tone waveform",range={0,2},default=0,unit='',increment=1,formatter=function(v) 
      val=math.floor(util.linlin(0,1,v.controlspec.minval,v.controlspec.maxval,v.raw))
      if val==0 then 
        return "sine"
      elseif val==1 then 
        return "triangle"
      elseif val==2 then 
        return "sawtooth"
      else
        return "?"
      end
    end},
    {id="oscFreq",name="tone freq freq",range={20,20000},default=1000,freq=true},
    {id="modMode",name="tone mod mode",range={0,2},default=0,unit='',increment=1,formatter=function(v) 
      val=math.floor(util.linlin(0,1,v.controlspec.minval,v.controlspec.maxval,v.raw))
      if val==0 then 
        return "decay"
      elseif val==1 then 
        return "sine"
      elseif val==2 then 
        return "random"
      else
        return "?"
      end
    end},
    {id="modAmt",name="tone mod amt",range={-96,96},default=0,unit='',increment=1,formatter=function(v) 
      val=math.floor(util.linlin(0,1,v.controlspec.minval,v.controlspec.maxval,v.raw))
      return ((val<0) and "" or "+")..val.." st"
    end},
    {id="modRate",name="tone mod rate",range={0.1,20000},default=17,freq=true},
    {id="oscAtk",name="tone attack",range={0,10000},default=0,increment=10,unit='ms'},
    {id="oscDcy",name="tone decay",range={0,10000},default=320,increment=10,unit='ms'},
    {id="nFilMod",name="noise filter mode",range={0,2},default=0,unit='',increment=1,formatter=function(v) 
      val=math.floor(util.linlin(0,1,v.controlspec.minval,v.controlspec.maxval,v.raw))
      if val==0 then 
        return "low-pass"
      elseif val==1 then 
        return "band-pass"
      elseif val==2 then 
        return "high-pass"
      else
        return "?"
      end
    end},
    {id="nFilFrq",name="noise filter freq",range={20,20000},default=1000,freq=true},
    {id="nFilQ",name="noise filter q",range={0.1,10000},default=0.7,curve='exp',unit='',increment=10},
    {id="nEnvMod",name="noise env mode",range={0,2},default=0,unit='',increment=1,formatter=function(v) 
      val=math.floor(util.linlin(0,1,v.controlspec.minval,v.controlspec.maxval,v.raw))
      if val==0 then 
        return "exponential"
      elseif val==1 then 
        return "linear"
      elseif val==2 then 
        return "modulated"
      else
        return "?"
      end
    end},
    {id="nEnvAtk",name="noise attack",range={0,10000},default=0,increment=10,unit='ms'},
    {id="nEnvDcy",name="noise decay",range={0,10000},default=320,increment=10,unit='ms'},
    {id="nStereo",name="noise stereo",range={0,1},default=0,unit='',increment=1,formatter=function(v) 
      val=math.floor(util.linlin(0,1,v.controlspec.minval,v.controlspec.maxval,v.raw))
      if val==0 then 
        return "off"
      elseif val==1 then 
        return "on"
      else
        return "?"
      end
    end},
  }
  self.param_names={}
  for _, p in ipairs(self.parameters) do
    table.insert(self.param_names,p.id)
  end
  params:add_group("DRUMMY",1+#self.parameters*drummer_number)
  local drum_options={}
  for i=1,drummer_number do 
    table.insert(drum_options,i)
  end
  params:add{type="option",id="selected",name="selected",options=drum_options,default=1,action=function(v)
    self:rebuild_menu(v)
    if _menu.mode then
      _menu.rebuild_params()
    end
  end}
  for i=1,drummer_number do
    for _,p in ipairs(self.parameters) do
      if p.freq==true then 
        params:add{type="control",id=i..p.id,name=p.name,controlspec=controlspec.new(p.range[1],p.range[2],'exp',0,p.default,'Hz'),formatter=Formatters.format_freq,action=function(v)
        end}
      else
        params:add{type="control",id=i..p.id,name=p.name,controlspec=controlspec.new(p.range[1],p.range[2],p.curve or 'lin',0,p.default,p.unit,(p.increment or 0.1)/(p.range[2]-p.range[1])),formatter=p.formatter,action=function(v)
        end}
      end
    end
  end

  self:rebuild_menu(1)
end

return Menu