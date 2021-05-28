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


function string.split(s,sep)
  local fields={}

  local sep=sep or " "
  local pattern=string.format("([^%s]+)",sep)
  string.gsub(s,pattern,function(c) fields[#fields+1]=c end)

  return fields
end


function sign(d)
  if d<0 then
    return -1
  else
    return 1
  end
end