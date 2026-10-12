local root=app.params.dir
local a=app.open(root..'/forest-stamps-before-cluster-expansion.aseprite')
local b=app.open(root..'/forest-stamps.aseprite')
local old=Image(a);local new=Image(b)
for y=0,a.height-1 do for x=0,a.width-1 do assert(old:getPixel(x,y)==new:getPixel(x,y),'Original pixels changed') end end
local p=app.open(app.params.palette)
local pal=Image(p.width,p.height,ColorMode.RGB);pal:drawSprite(p,1)
local allowed={}
for it in pal:pixels() do allowed[it()]=true end
for it in new:pixels() do local c=it();if app.pixelColor.rgbaA(c)>0 then assert(allowed[c],'Off-palette pixel') end end
assert(#b.slices==72,'Expected 72 named slices')
print('Original composite preserved; all pixels on game palette; 72 named slices; '..b.width..'x'..b.height)

