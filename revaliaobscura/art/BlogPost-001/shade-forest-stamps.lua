local root=app.params.dir
local sprite=app.open(root..'/forest-stamps.aseprite')
for _,layer in ipairs(sprite.layers) do if layer.name=='Three-color shading - toggle for silhouettes' then sprite:deleteLayer(layer) end end
local flat=Image(sprite)
local f=io.open(root..'/forest-stamps-before-three-color.json','r');local old=json.decode(f:read('*a'));f:close()
local named={};local intendedOrder={};local sequence=0
for _,entry in ipairs(old) do if entry and entry.name then named[entry.name]=entry;sequence=sequence+1;intendedOrder[entry.name]=sequence end end
local sourceFiles={'font-tree-stamps/manifest.json','organic-tree-stamps/manifest.json'}
for _,path in ipairs(sourceFiles) do
 f=io.open(root..'/'..path,'r');local list=json.decode(f:read('*a'));f:close()
 for _,entry in ipairs(list) do named[entry.name]=entry;if not intendedOrder[entry.name] then sequence=sequence+1;intendedOrder[entry.name]=sequence end end
end
local entries={}
for _,slice in ipairs(sprite.slices) do
 local bounds=slice.bounds;local meta=named[slice.name] or {}
 -- Fresh plain Lua tables avoid null entries produced by encoding JSON-backed tables.
 table.insert(entries,{name=slice.name,category=meta.category or 'Trees',x=bounds.x,y=bounds.y,w=bounds.width,h=bounds.height,source=meta.source,glyph=meta.glyph,artist=meta.artist,license=meta.license})
end
table.sort(entries,function(a,b) if a.y~=b.y then return a.y<b.y end return a.x<b.x end)
-- Preserve original gallery order: the first 72 entries' cells, then font glyphs, then organic variants.
local order=intendedOrder
table.sort(entries,function(a,b) return order[a.name]<order[b.name] end)
local function rgb(r,g,b) return app.pixelColor.rgba(r,g,b,255) end
local trunk=rgb(78,40,46);local branch=rgb(117,66,62);local green=rgb(108,140,80)
local leafShadow=rgb(43,103,78);local leafLight=rgb(103,193,118);local woodLight=rgb(199,139,80)
local overlay=Image(sprite.width,sprite.height,ColorMode.RGB);overlay:clear()
local function opaque(im,x,y) return x>=0 and y>=0 and x<im.width and y<im.height and app.pixelColor.rgbaA(im:getPixel(x,y))>0 end
local function stroke(im,p,color,t)
 for k=1,#p-2,2 do local ax,ay,bx,by=p[k],p[k+1],p[k+2],p[k+3];local n=math.max(math.abs(bx-ax),math.abs(by-ay))
  for i=0,n do local x=math.floor(ax+(bx-ax)*i/math.max(n,1)+.5);local y=math.floor(ay+(by-ay)*i/math.max(n,1)+.5)
   for dy=0,(t or 1)-1 do for dx=0,(t or 1)-1 do if opaque(im,x+dx,y+dy) then im:drawPixel(x+dx,y+dy,color) end end end
  end
 end
end
for index,e in ipairs(entries) do
 local im=Image(flat,Rectangle(e.x,e.y,e.w,e.h));local original=Image(im)
 local category=e.category
 local woody=category=='Branches' or category=='Branch kits' or (category=='Trunks' and e.name~='Pine silhouette') or e.name=='Root fan' or e.name=='Nest' or e.name:find('Gnarled bare')
 local whole=category=='Font tree silhouettes' or category=='Organic trees' or e.name=='Pine silhouette' or e.name=='Sapling'
 if woody then
  -- Three bark shades; thin upper forks remain warmer than the main limb.
  for it in im:pixels() do if app.pixelColor.rgbaA(it())>0 then
   local x,y=it.x,it.y;local localLight=.55*x/math.max(1,e.w-1)+.45*y/math.max(1,e.h-1)
   it(localLight>.63 and trunk or (localLight<.26 and woodLight or branch))
  end end
 elseif whole then
  for it in im:pixels() do if app.pixelColor.rgbaA(it())>0 then it(green) end end
  -- Track a visible trunk upward from the lowest opaque row.
  local center=e.w/2;local started=false;local limit=math.floor(e.h*.42)
  for y=e.h-1,limit,-1 do
   local runs={};local x=0
   while x<e.w do if opaque(original,x,y) then local a=x;while x<e.w and opaque(original,x,y) do x=x+1 end;table.insert(runs,{a,x-1}) else x=x+1 end end
   local best=nil;local distance=math.huge
   for _,run in ipairs(runs) do local d=math.abs((run[1]+run[2])/2-center);if d<distance then distance=d;best=run end end
   if best then
    local width=best[2]-best[1]+1
    if started and width>math.max(7,e.w*.28) then break end
    started=true;center=(best[1]+best[2])/2
    for xx=best[1],best[2] do im:drawPixel(xx,y,trunk) end
    -- Indicate the bark's lit edge with the same brown used for branches.
    if width>3 then im:drawPixel(best[1]+1,y,branch) end
   end
  end
  -- Colored structural branches extend into the existing silhouette without adding pixels.
  local cx=math.floor(center);local cy=math.floor(e.h*.67)
  stroke(im,{cx,cy,cx-math.floor(e.w*.17),math.floor(e.h*.46),cx-math.floor(e.w*.29),math.floor(e.h*.29)},branch,math.max(1,math.floor(e.w/55)))
  stroke(im,{cx,cy,cx+math.floor(e.w*.16),math.floor(e.h*.43),cx+math.floor(e.w*.27),math.floor(e.h*.25)},branch,math.max(1,math.floor(e.w/55)))
  stroke(im,{cx,cy,cx,math.floor(e.h*.27)},branch,1)
 elseif category=='Leaves' then
  -- Exactly three green tones, following the leaf's central fold rather than random texture.
  for it in im:pixels() do if app.pixelColor.rgbaA(it())>0 then
   local fold=e.w*.5+(it.y/e.h-.5)*e.w*.1
   it(it.x>fold and leafShadow or (it.x<fold-2 and it.y<e.h*.66 and leafLight or green))
  end end
 else
  -- Two coherent foliage tones plus a separate brown stem.
  for it in im:pixels() do if app.pixelColor.rgbaA(it())>0 then
   if category=='Details' then it(it.y>e.h*.65 and trunk or (it.y<e.h*.25 and woodLight or branch))
   else it(it.y/e.h+.3*it.x/e.w>.9 and leafShadow or green) end
  end end
  if category=='Foliage clusters' then
   for _,p in ipairs({{4,48,30,28,58,12},{24,32,23,7},{35,25,51,40},{46,19,64,26}}) do stroke(im,p,branch,1) end
  elseif e.name=='Ash compound leaf' then stroke(im,{17,47,17,3},branch,1)
  elseif e.name=='Rowan compound leaf' then stroke(im,{14,43,14,2},branch,1)
  elseif e.name=='Chestnut fan' then stroke(im,{23,43,23,35},branch,1)
  elseif e.name=='Birch twig' then stroke(im,{5,40,30,3},branch,1)
  elseif e.name=='Willow spray' then stroke(im,{0,4,39,13},branch,1)
  elseif e.name=='Oak spray' then stroke(im,{4,38,35,5},branch,2)
  elseif e.name=='Fern frond' then stroke(im,{16,47,20,0},branch,1)
  elseif e.name=='Paired beech leaves' then stroke(im,{17,33,19,8},branch,1)
  elseif e.name=='Drooping leaves' then stroke(im,{0,3,26,12},branch,1)
  elseif e.name=='Small fern' then stroke(im,{13,23,14,1},branch,1)
  elseif e.name=='Broad herb' then stroke(im,{10,22,10,5},branch,1)
  elseif e.name=='Flower stems' then stroke(im,{8,23,7,4,11,23,15,10},branch,1)
  elseif e.name=='Climbing vine' then stroke(im,{8,39,6,26,10,12,7,0},branch,1)
  elseif e.name=='Reeds' then stroke(im,{5,39,4,4},branch,1);stroke(im,{10,39,13,1},branch,1);stroke(im,{15,39,18,12},branch,1)
  end
 end
 local colors={}
 for y=0,e.h-1 do for x=0,e.w-1 do
  assert(app.pixelColor.rgbaA(im:getPixel(x,y))==app.pixelColor.rgbaA(original:getPixel(x,y)),'Stamp shape changed')
  if opaque(im,x,y) then colors[im:getPixel(x,y)]=true end
 end end
 local n=0;for _ in pairs(colors) do n=n+1 end;assert(n<=3,'More than three colors: '..e.name)
 overlay:drawImage(im,Point(e.x,e.y))
end
local guide=sprite:newLayer();guide.name='Three-color shading - toggle for silhouettes'
sprite:newCel(guide,1,overlay,Point(0,0))
-- The user's own paint layer stays above the guide for further edits.
for _,layer in ipairs(sprite.layers) do if layer.name=='Your shading' then layer.stackIndex=#sprite.layers end end
sprite:saveAs(root..'/forest-stamps.aseprite');Image(sprite):saveAs(root..'/forest-stamps.png')
f=io.open(root..'/forest-stamps.json','w');f:write(json.encode(entries));f:close()
local final=Image(sprite)
for y=0,sprite.height-1 do for x=0,sprite.width-1 do assert(app.pixelColor.rgbaA(final:getPixel(x,y))==app.pixelColor.rgbaA(flat:getPixel(x,y)),'Composite silhouette changed') end end
assert(#entries==106,'Missing gallery entries')
print('106 stamps recolored; max three colors per stamp; alpha silhouettes unchanged; gallery metadata restored')


