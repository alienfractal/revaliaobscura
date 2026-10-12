local root=app.params.dir
local source=app.open(root..'/forest-stamps.aseprite')
local f=io.open(root..'/forest-stamps.json','r');local items=json.decode(f:read('*a'));f:close()
assert(#items==96,'Expected 96 entries before adding organic trees')
f=io.open(root..'/organic-tree-stamps/manifest.json','r');local added=json.decode(f:read('*a'));f:close()
local base=source.height
local sprite=Sprite(320,base+1024,ColorMode.RGB)
for i,layer in ipairs(source.layers) do
 local dest=i==1 and sprite.layers[1] or sprite:newLayer();dest.name=layer.name;dest.opacity=layer.opacity;dest.isVisible=layer.isVisible
 local old=layer:cel(1)
 if old then local initial=dest:cel(1);if initial then sprite:deleteCel(initial) end;sprite:newCel(dest,1,Image(old.image),old.position) end
end
for _,slice in ipairs(source.slices) do local s=sprite:newSlice(slice.bounds);s.name=slice.name end
local layer=sprite:newLayer();layer.name='Organic tree silhouettes'
local image=Image(320,sprite.height,ColorMode.RGB);image:clear()
for i,item in ipairs(added) do
 if i<=5 then local n=i-1;item.x=(n%4)*80+math.floor((80-item.w)/2);item.y=base+math.floor(n/4)*128+116-item.h
 else local n=i-6;item.x=(n%2)*160+math.floor((160-item.w)/2);item.y=base+256+math.floor(n/2)*256+240-item.h end
 local im=Image{fromFile=root..'/organic-tree-stamps/'..item.file};image:drawImage(im,Point(item.x,item.y))
 local slice=sprite:newSlice(Rectangle(item.x,item.y,item.w,item.h));slice.name=item.name
 table.insert(items,item)
end
sprite:newCel(layer,1,image,Point(0,0))
sprite:saveAs(root..'/forest-stamps.aseprite');Image(sprite):saveAs(root..'/forest-stamps.png')
f=io.open(root..'/forest-stamps.json','w');f:write(json.encode(items));f:close()
local old=Image(source);local result=Image(sprite)
for y=0,source.height-1 do for x=0,source.width-1 do assert(old:getPixel(x,y)==result:getPixel(x,y),'Original artwork changed') end end
print('Added 10 organic stamps from five source designs; original composite unchanged')

