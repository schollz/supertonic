

-- -------------------------------------------------------------------------
-- STATE & MEMORY

curr_color = 0
curr_color_id = 0

curr_cursor_x = 0
curr_cursor_y = 0

curr_line_endpoint_x = nil
curr_line_endpoint_y = nil

function set_current_line_endpoints(x, y)
  curr_line_endpoint_x = x
  curr_line_endpoint_y = y
end

function invalidate_current_line_endpoints()
  curr_line_endpoint_x = nil
  curr_line_endpoint_y = nil
end

--- Read value in (emulated) memory
-- Only a subset of PICO-8 addresses are supported
-- @param addr index of the memory address
function peek(addr)
  if addr == 0x5f25 then
    return curr_color
  elseif addr == 0x5f26 then
    return curr_cursor_x
  elseif addr == 0x5f27 then
    return curr_cursor_y
  end
end

--- Set value in (emulated) memory
-- Only a subset of PICO-8 addresses are supported
-- @param addr index of the memory address
-- @param val valu to set
function poke(addr, val)
  if addr == 0x5f25 then
    color(val)
  end
end


-- -------------------------------------------------------------------------
-- UTILS

local function arraylen(t)
  local len = 0
  for i, _ in pairs(t) do
    if type(i) == "number" then
      len = i
    end
  end
  return len
end

-- TODO: replace by `tabutil.key`
local function find_in_table(search_v, t)
  local index={}
  for k, v in pairs(t) do
    if v == search_v then
      return k
    end
  end
end

--- Create a range iterator
-- @param a start value
-- @param b end value
-- @param step step between values, defaults to 1
function range(a, b, step)
  if not b then
    b = a
    a = 1
  end
  step = step or 1
  local f =
    step > 0 and
    function(_, lastvalue)
      local nextvalue = lastvalue + step
      if nextvalue <= b then return nextvalue end
    end or
    step < 0 and
    function(_, lastvalue)
      local nextvalue = lastvalue + step
      if nextvalue >= b then return nextvalue end
    end or
    function(_, lastvalue) return lastvalue end
  return f, nil, a - step
end


-- -------------------------------------------------------------------------
-- TABLES

--- Syntactic sugar around `for`
-- @param a table to iterrate over
-- @param f function to apply to each element
function foreach(a, f)
  if not a then
    -- warning("foreach got a nil value")
    return
  end
  for _, v in ipairs(a) do
    f(v)
  end
end

--- Create an itarator on table
-- @param a table to iterrate over
function all(a)
  if a == nil then
    return function()
    end
  end

  local i = 0
  local n = arraylen(a)
  return function()
    i = i + 1
    while (a[i] == nil and i <= n) do
      i = i + 1
    end
    return a[i]
  end
end

--- Syntactic sugar around `table.insert`
-- @param a table to insert into
-- @param v value to insert
function add(a, v)
  if a == nil then
    -- warning("add to nil")
    return
  end
  table.insert(a, v)
  return v
end

--- Syntactic sugar around `table.remove`
-- @param a table to alter
-- @param dv value of element to remove
function del(a, dv)
  if a == nil then
    -- warning("del from nil")
    return
  end
  for i, v in ipairs(a) do
    if v == dv then
      table.remove(a, i)
      return dv
    end
  end
end


-- -------------------------------------------------------------------------
-- TIME

curr_time = .0

time_fps = 10

clock.run(
  function()
    while curr_time < 32767 do
      local step_s = 1 / time_fps
      curr_time = curr_time + step_s
      clock.sleep(step_s)
    end

    curr_time = 32767
end)


--- Get current elapsed time
-- Please note that it will stop counting at 32767 seconds
function t()
  return curr_time
end


-- -------------------------------------------------------------------------
-- MATH: BASICS

--- Returns the sign of number
-- @param x number to analyze
function sgn(x)
  if x < 0 then
    return -1
  else
    return 1
  end
end

--- Get the median value out of 3 values
-- @param x first number
-- @param y second number
-- @param z thirs number
function mid(x, y, z)
  x = flr(x)
  y = flr(y)
  z = flr(z)
  mx = max(max(x, y), z)
  mn = min(min(x ,y), z)
  return x ~ y ~ z ~ mx ~ mn
end

--- Get the minimum out of 2 numbers
-- @param x first number
-- @param y second number
function min(x, y)
  return math.min(x, y)
end

--- Get the maximum out of 2 numbers
-- @param x first number
-- @param y second number
function max(x, y)
  return math.max(x, y)
end

--- Compute the absolute value
-- @param x number
function abs(x)
  return math.abs(x)
end

--- Compute the square root
-- @param x number
function sqrt(x)
  if x < 0 then
    return 0
  end
  return math.sqrt(x)
end

--- Floors value
-- @param x number
function flr(x)
  return math.floor(x)
end

--- Round value
-- @param x number
-- @param numDecimalPlaces precision
-- NB: not in standard PICO-8 API
-- but PICO-8 seems to `round` (instead of `floor`) some params in some cases
function round(x, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(x * mult + 0.5) / mult
end


-- -------------------------------------------------------------------------
-- MATH: BINARY OPS

--- Binary and
function band(x, y)
  return x & y
end

--- Binary not
function bnot(x)
  return ~x
end

--- Binary or
function bor(x, y)
  return x | y
end

--- Binary xor
function bxor(x, y)
  return x ~ y
end

--- Binary shift to the left
function shl(num, bits)
  return num << bits
end

--- Binary shift to the right
function shr(num, bits)
  return num >> bits
end


-- -------------------------------------------------------------------------
-- MATH: RANDOMNESS

--- Generate a random value
-- The returned value is a float
-- @param x max value, defaults to 0
function rnd(x)
  if x == 0 then
    return 0
  end
  if (not x) then
    x = 1
  end
  x = x * 100000
  x = math.random(x) / 100000
  return x
end

--- Generate a random seed to improve `rnd` randomness
-- @param x seed value, defaults to 0
function srand(x)
  if not x then
    x = 0
  end
  math.randomseed(x)
end


-- -------------------------------------------------------------------------
-- MATH: TRIGONOMETRY

--- Cos of value
-- Value is expected to be between 0..1 (instead of 0..360)
-- @param x value
function cos(x)
  if x==nil then 
    do return 0 end 
  end
  return math.cos(math.rad(x * 360))
end

--- Cos of value
-- Value is expected to be between 0..1 (instead of 0..360)
-- Result is sign-inverted, as per PICO-8 convention
-- @param x value
function sin(x)
  if x==nil then 
    do return 0 end 
  end
  return -math.sin(math.rad(x * 360))
end

--- Arctangent of point
-- @param dx point location on the x axis
-- @param dy point location on the y axis
function atan2(dx, dy)
  local q = 0.125
  local a = 0
  local ay = abs(dy)
  if ay == 0 and dx ==0 then
    ay = 0.001
  end
  if dx >= 0 then
    local r = (dx - ay) / (dx + ay)
    a = q - r*q
  else
    local r = (dx + ay) / (ay - dx)
    a = q*3 - r*q
  end
  if dy > 0 then
    a = -a
  end
  return a
end



-- -------------------------------------------------------------------------
-- SCREEN: BASICS

--- Clear screen
-- @param col index of color in current palette, defaults to 0
function cls(col)
  cursor(0, 0)
  if not col then
    col = 0
  end
  rectfill(0, 0, 128, 64, col)
end

--- Apply changes to the actual screen
function flip()
  screen.update()
end


-- -------------------------------------------------------------------------
-- SCREEN: COLORS

default_palette_indices = {
  -- standard
  0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
  -- secret
  128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143,
}
default_palette = {
  -- standard
  {   0,   0,   0 }, -- black          0
  {  29,  43,  83 }, -- dark-blue      3
  { 126,  37,  83 }, -- dark-purple    4
  {   0, 135,  81 }, -- dark-green     4
  { 171,  82,  54 }, -- brown          6
  {  95,  87,  79 }, -- dark-grey      5
  { 194, 195, 199 }, -- light-grey     11
  { 255, 241, 232 }, -- white          14
  { 255,   0,  77 }, -- red            6
  { 255, 163,   0 }, -- orange         8
  { 255, 236,  39 }, -- yellow         10
  {   0, 228,  54 }, -- green          5
  {  41, 173, 255 }, -- blue           9
  { 131, 118, 156 }, -- lavender       7
  { 255, 119, 168 }, -- pink           10
  { 255, 204, 170 }, -- light-peach    12
  -- secret
  {  41,  24,  20 }, -- darkest-grey   1
  {  17,  29,  53 }, -- darker-blue    1
  {  66,  33,  54 }, -- darker-purple  3
  {  18,  83,  89 }, -- blue-green     3
  { 116,  47,  41 }, -- dark-brown     4
  {  73,  51,  59 }, -- darker-grey    3
  { 162, 136, 121 }, -- medium-grey    8
  { 243, 239, 125 }, -- light-yellow   11
  { 190,  18,  80 }, -- dark-red       5
  { 255, 108,  36 }, -- dark-orange    7
  { 168, 231,  46 }, -- light-green    8
  { 0,   181,  67 }, -- medium-green   4
  { 6,    90, 181 }, -- medium-blue    5
  { 117,  70, 101 }, -- mauve          5
  { 255, 110,  89 }, -- dark peach     8
  { 255, 157, 129 }, -- peach          10
}
default_palette_transparency = {}
for i in range(#default_palette + 1) do
  default_palette_transparency[i] = false
end

curr_palette = default_palette
curr_palette_transparency = default_palette_transparency

--- Convert RGB tuple to 16-levels greyscale
-- @param rgb table of 3 RGB values
local function rgb_to_greyscale(rgb)
  local r = rgb[1]
  local g = rgb[2]
  local b = rgb[3]
  local grey_255 = (r + g + b) / 3
  local grey_16 = grey_255 * 15 / 255
  return flr(grey_16)
end

--- Set current active color
-- @param col index of color in current palette
function color(col)
  -- NB: secret colors can only be accessed through `pal`
  col = flr(col % 16)
  curr_color_id = col + 1
  curr_color = rgb_to_greyscale(curr_palette[curr_color_id])
  screen.level(curr_color)
end

--- Set current active color, if set
-- @param col index of color in current palette
local function color_maybe(col)
  if col then
    color(col)
  end
end

--- Sanitize argument into a valid index in color palette
-- Notably support access to the "secret" palette through a special range of index values or negative values
-- @param col index in color palette
local function normalize_col_for_pal(col)
  col = flr(col)

  if col >= 128 and col <= 143 then
    -- direct access to secret palette
    return col
  elseif col >= -144 and col <= -129 then
    -- direct access to regular palette with negative value
    return col % 16
  end

  local sign = 1
  if col < 0 then sign = -1 end

  -- NB: negative values are shorthands to the secret palette
  if sign == -1 then
    return 128 + 16 + col
  end

  return col % 16
end

--- Internal implementation of `pal`'s table support
-- @param t map of values indices to alter
-- @param p whether to apply directly or not, not honored
local function pal_table(t, p)
  for in_col, out_col in pairs(t) do
    -- print("pal map: "..normalize_col_for_pal(in_col).." -> "..normalize_col_for_pal(out_col))
    pal(in_col, out_col, p)
  end
end

--- Alter current color palette
-- If called with no arguments, restores defautl palette (and resets transparency).
-- Can also be called with a map of color swaps in the first argument.
-- in that case, second argument becomes interpreted as `p`.
-- @param c0 index in palette to replace
-- @param c1 index of color taking its place
-- @param p whether to apply directly or not, not honored
function pal(c0, c1, p)
  -- NB: use-case of p=0 is not clear to me

  if not c0 then
    curr_palette = default_palette
    palt() -- reset transparency
  elseif type(c0) == "table" then
    pal_table(c0, c1) -- NB: in that case 2nd arg (c2) acts as p
  else
    c0 = normalize_col_for_pal(c0)
    c1 = normalize_col_for_pal(c1)
    c0_id = find_in_table(c0, default_palette_indices)
    c1_id = find_in_table(c1, default_palette_indices)
    curr_palette[c0_id] = curr_palette[c1_id]
  end
end

--- Alter color transparency flag
-- If called with no argument, disable all transparency
-- @param col index of color in current palette
-- @param t truthy means transparent
function palt(col, t)
  local col_id = find_in_table(col, default_palette_indices)
  if not col then
    curr_palette_transparency = default_palette_transparency
  else
    curr_palette_transparency[col_id] = t
  end
end

--- Return true if color is to be considered transparent
-- @param col index of color in current palette
local function is_color_transparent(col)
  local col_id = nil
  if col then
    col_id = find_in_table(col, default_palette_indices)
  else
    col_id = curr_color_id
  end
  return curr_palette_transparency[col_id]
end



-- -------------------------------------------------------------------------
-- SCREEN: TEXT

--- Set current text cursor position
-- Optionally set the current color.
-- @param x position on the X axis
-- @param y position on the Y axis
-- @param col index of color in current palette
function cursor(x, y, col)
  color_maybe(col)
  if x then
    curr_cursor_x = x
  end
  if y then
    curr_cursor_y = y
  end
  screen.move(curr_cursor_x, curr_cursor_y)
end

--- Print text on screnn
-- Called `print` in PICO-8, but we can't override safely Lua's default print
-- @param str text to print
-- @param x position on the X axis
-- @param y position on the Y axis
-- @param col index of color in current palette
function p8print(str, x, y, col)
  cursor(x, y, col)

  -- TODO: handle \n and whole screen scroll on value wrap

  if not is_color_transparent() then
    screen.text(str)
  end

  curr_cursor_y = curr_cursor_y + 6
  if (curr_cursor_y + 6) >= 128 then
    curr_cursor_y = 0
  end
end


-- -------------------------------------------------------------------------
-- SCREEN: SHAPES

--- Get the 16-level grayscale value of pixel on screen
-- Please note that contrarilly to PICO-8, this doesn't correspond to the index in current color palette.
-- @param x position on the X axis
-- @param y position on the Y axis
function pget(x, y)
  x = round(x)
  y = round(y)
  local s = screen.peek(x, y, x+1, y+1)
  if s == nil then
    return 0
  end
  return string.byte(s, 1)
end

--- Draw pixel on screen
-- @param x position on the X axis
-- @param y position on the Y axis
-- @param col index of color in current palette
function pset(x, y, col)
  color_maybe(col)
  if is_color_transparent() then
    return
  end
  screen.pixel(x, y)
  screen.fill()
end

local function line_w_start(x0, y0, x1, y1, col)
  color_maybe(col)

  if is_color_transparent() then
    return
  end

  screen.move(x0, y0)
  screen.line(x1, y1)
  screen.stroke()

  set_current_line_endpoints(x1, y1)
end

local function line_w_no_start(x1, y1, col)
  color_maybe(col)

  if is_color_transparent() then
    return
  end

  if curr_line_endpoint_x and curr_line_endpoint_y then
    screen.move(curr_line_endpoint_x, curr_line_endpoint_y)
    screen.line(x1, y1)
    screen.stroke()
  end

  set_current_line_endpoints(x1, y1)
end

--- Draw line on screen
function line(a1, a2, a3, a4, a5)
  if not a1 then
    invalidate_current_line_endpoints()
  elseif not a2 then
    color_maybe(a1)
    invalidate_current_line_endpoints()
  elseif not a4 then
    line_w_no_start(a1, a2, a3)
  else
    line_w_start(a1, a2, a3, a4, a5)
  end
end

--- Draw circle on screen
-- @param x center position on the X axis
-- @param y center position on the Y axis
-- @param r circle radius
-- @param col index of color in current palette
function circ(x, y, r, col)
  color_maybe(col)
  if is_color_transparent() then
    return
  end
  screen.move(x + r, y)
  screen.circle(x, y, r)
  screen.stroke()
end

--- Draw filled circle on screen
-- @param x center position on the X axis
-- @param y center position on the Y axis
-- @param r circle radius
-- @param col index of color in current palette
function circfill(x, y, r, col)
  color_maybe(col)
  if is_color_transparent() then
    return
  end
  screen.move(x + r, y)
  screen.circle(x, y, r)
  screen.fill()
end

--- Draw rectangle on screen
function rect(x0, y0, x1, y1, col)
  color_maybe(col)
  if is_color_transparent() then
    return
  end
  screen.rect(x0, y0, (x1 - x0), (y1 - y0))
  screen.stroke()
end

--- Draw filled rectangle on screen
function rectfill(x0, y0, x1, y1, col)
  color_maybe(col)
  if is_color_transparent() then
    return
  end
  screen.rect(x0, y0, (x1 - x0), (y1 - y0))
  screen.fill()
end
