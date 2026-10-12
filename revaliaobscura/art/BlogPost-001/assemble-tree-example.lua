local root=app.params.dir
local f=io.open(root..'/forest-stamps.json','r');local items=json.decode(f:read('*a'));f:close()
local src=Image{fromFile=root..'/forest-stamps.aseprite'}
local function crop(n) local a=items[n];return Image(src,Rectangle(a.x,a.y,a.w,a.h)) end
local tree=Sprite(240,200,ColorMode.RGB)
tree.layers[1].name='Trunk';tree:newCel(tree.layers[1],1,crop(1),Point(104,65))
local branchLayer=tree:newLayer();branchLayer.name='Oak branches'
local branches=Image(240,200,ColorMode.RGB);branches:clear()
for i=1,3 do local rootY=({47,28,7})[i];local y=({82,106,130})[i];local b=crop(48+i)
 branches:drawImage(b,Point(116,y-rootY))
 b:flip(FlipType.HORIZONTAL);branches:drawImage(b,Point(108-75,y-rootY+4))
end
tree:newCel(branchLayer,1,branches,Point(0,0))
local foliageLayer=tree:newLayer();foliageLayer.name='Overlapping oak clusters'
local foliage=Image(240,200,ColorMode.RGB);foliage:clear()
for _,p in ipairs({{136,26},{149,58},{142,91},{86,4}}) do foliage:drawImage(crop(61),Point(p[1],p[2])) end
for _,p in ipairs({{10,29},{0,62},{9,94},{56,9}}) do local c=crop(62);c:flip(FlipType.HORIZONTAL);foliage:drawImage(c,Point(p[1],p[2])) end
tree:newCel(foliageLayer,1,foliage,Point(0,0))
tree:newLayer().name='Your shading'
tree:saveAs(root..'/oak-tree-assembly-example.aseprite')
Image(tree):saveAs(root..'/oak-tree-assembly-example.png')
print('Saved editable tree example, assembled from library stamps')
