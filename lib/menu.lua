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


function Menu:rebuild_menu(selected,selected_patch)
  for _,p in ipairs(self.parameters) do
    for i=1,drummer_number do
      if i==selected and p.hidden==nil then
        params:show(i..p.id)
      else
        params:hide(i..p.id)
      end
    end
  end
  for _,p in ipairs(self.parameters_morph) do
    for patch=1,2 do
      for i=1,drummer_number do
        if i==selected and p.hidden==nil and patch==selected_patch then
          params:show(i..patch..p.id)
        else
          params:hide(i..patch..p.id)
        end
      end
    end
  end
  for patch=1,2 do
    if patch==selected_patch then
      params:show(patch.."preset")
    else
      params:hide(patch.."preset")
    end
  end
end

function Menu:init()
  params.action_read=function(filename,silent)
    print("read file!")
    for i=1,5 do
      drummer[i]:set_pattern(params:get(i.."pattern"))
    end
  end
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
  self.parameters_morph={
    -- TODO: add string of the current pattern
    {id="level",name="level",range={-100,10},default=0,unit='dB'},
    {id="distAmt",name="distortion",range={0,100},default=0,unit='',increment=1},
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
    {id="oscVel",name="osc velocity",range={0,200},default=100,increment=1,unit='%'},
    {id="modVel",name="mod velocity",range={0,200},default=100,increment=1,unit='%'},
    {id="nVel",name="noise velocity",range={0,200},default=100,increment=1,unit='%'},
  }
  self.parameters={
    {id="morph",name="morph blend",range={0,1},default=0,increment=0.01},
    {id="pattern",name="pattern",hidden=true,textmenu=true},
    {id="basis",name="basis",range={1,5},default=1,increment=1,hidden=true},
  }
  params:add_group("SUPERTONIC",7+(#self.parameters*drummer_number)+(#self.parameters_morph*drummer_number*2))
  local drum_options={}
  for i=1,drummer_number do
    table.insert(drum_options,i)
  end
  params:add{type="control",id="global lpf freq",name="global lpf freq",controlspec=controlspec.new(20,20000,'exp',0,20000,'Hz',100/20000),formatter=Formatters.format_freq,action=function(v)
    for i=1,5 do
      engine.supertonic_lpf(i,v,params:get("global lpf rq"))
    end
  end}
  params:add{type="control",id="global lpf rq",name="global lpf rq",controlspec=controlspec.new(0.05,1,'lin',0,1,'',0.01/0.95),action=function(v)
    for i=1,5 do
      engine.supertonic_lpf(i,params:get("global lpf freq"),v)
    end
  end}
  params:add_separator("supertonic engine params")
  local preset_dir=_path.data.."supertonic/presets/"
  for i=1,2 do
    params:add_file(i.."preset","preset",preset_dir)
    params:set_action(i.."preset",function(v)
      if v==preset_dir then
        do return end
      end
      print(preset_dir)
      local patches=supertonic_patches:load(v)
      if patches~=nil then
        for dnum=1,5 do
          drummer[dnum]:set_patch(i,patches[dnum])
        end
      end
    end)
  end
  params:add{type="option",id="selected",name="instrument",options={"kick","snare","hi-hat","open hat","clap"},default=1,action=function(v)
    self:rebuild_menu(v,params:get("patch"))
    if _menu.mode then
      _menu.rebuild_params()
    end
  end}
  params:add{type="option",id="patch",name="patch",options={"1","2"},default=1,action=function(v)
    self:rebuild_menu(params:get("selected"),v)
    if _menu.mode then
      _menu.rebuild_params()
    end
    params:set(params:get("selected").."morph",v-1)
  end}
  for dnum=1,drummer_number do
    for _,p in ipairs(self.parameters) do
      self:add_menu(dnum,p)
      params:set_action(dnum..p.id,function(v)
        drummer[dnum].update=true
      end)
    end
    for patch=1,2 do
      for _,p in ipairs(self.parameters_morph) do
        self:add_menu(dnum..""..patch,p,true)
        params:set_action(dnum..""..patch..p.id,function(v)
          drummer[dnum].update=true
        end)
      end
    end
  end
  for dnum=1,drummer_number do 
    params:set_action(dnum.."morph",function(v)
      if v==0 then 
        params:set("patch",1)
      elseif v==1 then 
        params:set("patch",2)
      end
      drummer[dnum].update=true
    end)
  end
  self:rebuild_menu(1,1)
end

function Menu:add_menu(i,p)
  if p.freq==true then
    params:add{type="control",id=i..p.id,name=p.name,controlspec=controlspec.new(p.range[1],p.range[2],'exp',0,p.default,'Hz'),formatter=Formatters.format_freq,action=function(v)
    end}
  elseif p.textmenu~=nil then
    params:add_text(i..p.id,p.name,"")
  elseif p.isnumber~=nil then
    params:add_number(i..p.id,p.name,p.range[1],p.range[2],1)
  else
    params:add{type="control",id=i..p.id,name=p.name,controlspec=controlspec.new(p.range[1],p.range[2],p.curve or 'lin',0,p.default,p.unit,(p.increment or 0.1)/(p.range[2]-p.range[1])),formatter=p.formatter,action=function(v)
    end}
  end

end
return Menu
