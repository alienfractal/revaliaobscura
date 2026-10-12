local root=app.params.dir
local source=app.open(root..'/forest-stamps.aseprite')
local f=io.open(root..'/forest-stamps.json','r');local items=json.decode(f:read('*a'));f:close()
assert(#items==72,'Expected 72 existing entries before adding font silhouettes')
f=io.open(root..'/font-tree-stamps/manifest.json','r');local added=json.decode(f:read('*a'));f:close()
local height=math.ceil((#items+#added)/4)*128
local sprite=Sprite(320,height,ColorMode.RGB)
for i,layer in ipairs(source.layers) do
 local dest=i==1 and sprite.layers[1] or sprite:newLayer();dest.name=layer.name;dest.opacity=layer.opacity;dest.isVisible=layer.isVisible
 local old=layer:cel(1)
 if old then local initial=dest:cel(1);if initial then sprite:deleteCel(initial) end;sprite:newCel(dest,1,Image(old.image),old.position) end
end
for _,slice in ipairs(source.slices) do local s=sprite:newSlice(slice.bounds);s.name=slice.name end
local layer=sprite:newLayer();layer.name='Font tree silhouettes'
local image=Image(320,height,ColorMode.RGB);image:clear()
for _,item in ipairs(added) do
 local n=#items;item.x=(n%4)*80+math.floor((80-item.w)/2);item.y=math.floor(n/4)*128+116-item.h
 local im=Image{fromFile=root..'/font-tree-stamps/'..item.file}
 image:drawImage(im,Point(item.x,item.y))
 local slice=sprite:newSlice(Rectangle(item.x,item.y,item.w,item.h));slice.name=item.name
 table.insert(items,item)
end
sprite:newCel(layer,1,image,Point(0,0))
sprite:saveAs(root..'/forest-stamps.aseprite');Image(sprite):saveAs(root..'/forest-stamps.png')
f=io.open(root..'/forest-stamps.json','w');f:write(json.encode(items));f:close()
local old=Image(source);local result=Image(sprite)
for y=0,source.height-1 do for x=0,source.width-1 do assert(old:getPixel(x,y)==result:getPixel(x,y),'Original artwork changed') end end
print('Added 24 font trees; 96 named gallery entries; existing artwork unchanged')
