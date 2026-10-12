local dir = app.params.dir
local source = app.open(dir .. '/metsavana-pixel-1.png')
assert(source and source.width == 171 and source.height == 150, 'Unexpected source dimensions')
local flat = Image(171,150,ColorMode.RGB)
flat:drawSprite(source, 1)
local result = Sprite(171, 150, ColorMode.RGB)
local names = {'Forest', 'Legs', 'Torso', 'Arms', 'Head', 'Creatures and plants'}
local layers, images, counts = {}, {}, {}
for i,name in ipairs(names) do
  local layer = i == 1 and result.layers[1] or result:newLayer()
  layer.name = name
  layers[i] = layer
  images[i] = Image(171,150,ColorMode.RGB)
  images[i]:clear()
  counts[i] = 0
end
local function inside(x,y,p)
  local yes=false; local j=#p-1
  for i=1,#p,2 do
    local ax,ay,bx,by=p[i],p[i+1],p[j],p[j+1]
    if ((ay>y) ~= (by>y)) and (x < (bx-ax)*(y-ay)/(by-ay)+ax) then yes=not yes end
    j=i
  end
  return yes
end
local head={71,24,83,21,97,25,104,35,105,53,101,68,98,77,91,86,83,90,76,81,72,71,68,63,66,50,67,36}
local figure={61,31,71,24,98,25,104,34,117,38,128,50,130,68,124,80,126,94,127,103,129,121,127,135,118,139,108,135,95,142,82,139,76,138,64,136,54,135,44,129,40,119,46,111,39,104,39,94,44,78,44,65,47,51,54,43}
local leftArm={50,58,62,56,71,64,77,75,77,85,68,94,56,95,43,88,43,81,48,74,46,67}
local rightArm={103,58,118,56,127,63,127,75,122,83,123,93,115,99,105,102,87,103,80,99,78,91,86,87,98,83,108,77,104,70}
local legs={51,110,67,110,78,117,81,105,90,99,103,100,113,106,113,117,122,116,128,123,129,133,120,138,110,134,105,140,90,143,80,138,69,137,56,136,45,132,44,123}
local leftShoulder={47,43,57,38,68,42,72,49,71,62,66,72,55,77,46,69,44,58}
local rightShoulder={102,41,113,38,123,43,128,53,126,65,121,79,109,77,102,66}
local hornsLeft={57,26,62,18,68,19,70,32,68,43,57,45,52,38}
local hornsRight={104,27,113,20,120,16,119,24,115,33,122,39,129,40,130,50,118,53,108,41}
local bird={147,52,150,47,157,46,162,49,159,53,161,57,160,65,169,63,170,75,163,80,151,79,146,75,146,66,148,61}
local nest={140,74,151,75,162,75,170,71,171,81,163,87,153,88,141,82}
local stems={149,86,156,85,157,93,159,92,169,96,169,122,160,131,151,128,151,112}
local gnomeLeft={47,117,51,111,54,111,58,122,56,130,49,132,43,126}
local gnomeRight={125,119,132,115,137,119,139,128,133,134,125,131}
local forestColors={['42,106,106']=true,['79,109,111']=true,['61,67,86']=true}
for y=0,149 do for x=0,170 do
  local pixel=flat:getPixel(x,y)
  if app.pixelColor.rgbaA(pixel)>0 then
    local r,g,b=app.pixelColor.rgbaR(pixel),app.pixelColor.rgbaG(pixel),app.pixelColor.rgbaB(pixel)
    local key=r..','..g..','..b
    local green=(g>r*1.08 and g>=b*.9)
    local skin=(r>g*1.2 and g>b*1.15 and r>140)
    local background=forestColors[key]
    local index=1
    if inside(x,y,head) and not background then index=5
    elseif inside(x,y,bird) or inside(x,y,nest) then
      if not background and key~='27,58,47' and key~='43,103,78' then index=6 end
    elseif inside(x,y,stems) then
      if green and not background and key~='27,58,47' then index=6 end
    elseif (inside(x,y,gnomeLeft) or inside(x,y,gnomeRight)) and not background and key~='27,58,47' then index=6
    elseif (inside(x,y,hornsLeft) or inside(x,y,hornsRight)) and not background and key~='27,58,47' then index=6
    elseif inside(x,y,figure) and not background then
      if inside(x,y,leftShoulder) or inside(x,y,rightShoulder) then
        if green or not skin then index=6 else index=4 end
      elseif inside(x,y,leftArm) or inside(x,y,rightArm) then
        if green then index=6 else index=4 end
      elseif inside(x,y,legs) then index=2
      else index=3 end
    elseif x>=112 and x<=143 and y>=99 and y<=104 and not background and not green then index=4
    elseif (x<43 or x>130 or y>135) and y>91 and green and key~='27,58,47' and key~='42,106,106' then index=6
    end
    if skin and x>=40 and x<=131 and y>=50 and y<=140 and index~=5 then
      if y>=108 then index=2 else index=4 end
    end
    images[index]:drawPixel(x,y,pixel)
    counts[index]=counts[index]+1
  end
end end
for i=1,6 do
  local existing=layers[i]:cel(1)
  if existing then result:deleteCel(existing) end
  result:newCel(layers[i],1,images[i],Point(0,0))
  images[i]:saveAs(dir..'/metsavana-layer-'..string.lower(names[i]):gsub(' ','-')..'.png')
  print(names[i]..': '..counts[i]..' pixels')
end
result:saveAs(dir..'/metsavana-pixel-1-layered.aseprite')
local check=Image(171,150,ColorMode.RGB)
check:drawSprite(result,1)
local errors=0
for y=0,149 do for x=0,170 do if check:getPixel(x,y)~=flat:getPixel(x,y) then errors=errors+1 end end end
assert(errors==0,'Composite mismatch: '..errors)
check:saveAs(dir..'/metsavana-pixel-1-layered-preview.png')
print('Verified exact composite; six layers; 171x150')


