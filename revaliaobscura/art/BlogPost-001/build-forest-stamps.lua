local dir=app.params.dir
local items={}
local function polygon(im,p,col)
 local j=#p-1
 for y=0,im.height-1 do for x=0,im.width-1 do
  local hit=false;j=#p-1
  for i=1,#p,2 do local ax,ay,bx,by=p[i],p[i+1],p[j],p[j+1]
   if ((ay>y)~=(by>y)) and x<(bx-ax)*(y-ay)/(by-ay)+ax then hit=not hit end;j=i end
  if hit then im:drawPixel(x,y,col) end
 end end
end
local function line(im,x0,y0,x1,y1,c,t)
 local n=math.max(math.abs(x1-x0),math.abs(y1-y0))
 for i=0,n do local x=math.floor(x0+(x1-x0)*i/math.max(1,n)+.5);local y=math.floor(y0+(y1-y0)*i/math.max(1,n)+.5)
  for dy=0,(t or 1)-1 do for dx=0,(t or 1)-1 do if x+dx<im.width and y+dy<im.height and x+dx>=0 and y+dy>=0 then im:drawPixel(x+dx,y+dy,c) end end end end
end
local function oval(im,cx,cy,rx,ry,c)
 for y=math.max(0,cy-ry),math.min(im.height-1,cy+ry) do for x=math.max(0,cx-rx),math.min(im.width-1,cx+rx) do
 if ((x-cx)/rx)^2+((y-cy)/ry)^2<=1 then im:drawPixel(x,y,c) end end end
end
local function rgba(r,g,b) return app.pixelColor.rgba(r,g,b,255) end
local wood=rgba(117,66,62);local green=rgba(108,140,80);local herb=rgba(62,153,107);local warm=rgba(199,139,80)
local function add(name,category,w,h,color,fn)
 local im=Image(w,h,ColorMode.RGB);im:clear();fn(im,color)
 local n=#items;local x=(n%4)*80+math.floor((80-w)/2);local y=math.floor(n/4)*128+116-h
 table.insert(items,{name=name,category=category,x=x,y=y,w=w,h=h,image=im})
end
add('Straight trunk','Trunks',24,112,wood,function(im,c) polygon(im,{8,0,17,0,16,76,20,105,24,111,0,111,7,100,9,61},c) end)
add('Bent trunk','Trunks',30,108,wood,function(im,c) polygon(im,{3,0,12,0,14,26,23,57,21,90,29,107,0,107,11,94,14,61,5,31},c) end)
add('Forked trunk','Trunks',40,112,wood,function(im,c) polygon(im,{16,111,25,111,24,56,35,31,40,0,33,0,28,27,20,44,12,27,8,1,1,0,4,31,16,55},c) end)
add('Pine silhouette','Trunks',40,92,green,function(im,c) polygon(im,{19,0,25,16,22,16,30,30,26,30,34,45,29,45,39,65,24,64,24,91,16,91,16,65,0,65,10,46,5,46,14,30,10,30,17,16,13,16},c) end)
add('Rising branch','Branches',48,32,wood,function(im,c) polygon(im,{0,25,17,20,27,12,39,0,43,0,33,14,24,24,0,31},c);line(im,20,21,18,5,c,2);line(im,30,15,47,11,c,2) end)
add('Wide fork','Branches',48,30,wood,function(im,c) line(im,0,26,25,15,c,4);line(im,25,15,47,14,c,3);line(im,25,15,38,1,c,3);line(im,12,21,9,7,c,2) end)
add('Hanging branch','Branches',48,34,wood,function(im,c) line(im,0,2,22,11,c,4);line(im,22,11,43,24,c,3);line(im,43,24,45,32,c,2);line(im,25,13,36,7,c,2) end)
add('Bare twig','Branches',28,26,wood,function(im,c) line(im,1,24,20,6,c,2);line(im,10,16,8,3,c,1);line(im,17,9,26,8,c,1);line(im,19,7,20,0,c,1) end)
add('Small leaf','Foliage',10,14,green,function(im,c) polygon(im,{8,0,9,6,6,10,1,13,0,7,3,3},c) end)
add('Leaf fan','Foliage',26,20,green,function(im,c) polygon(im,{12,19,5,16,0,8,4,7,10,12,7,2,11,0,14,11,18,1,22,3,18,12,25,8,25,13,18,18},c) end)
add('Canopy cluster','Foliage',48,30,green,function(im,c) oval(im,12,17,11,8,c);oval(im,25,10,13,9,c);oval(im,37,18,10,8,c);oval(im,24,22,13,7,c);polygon(im,{3,13,1,9,8,10,9,4,14,7,32,2,34,8,43,8,41,14},c) end)
add('Drooping leaves','Foliage',32,28,green,function(im,c) line(im,0,3,26,12,c,1);for i=0,3 do local x=4+i*6;polygon(im,{x,5+i*2,x+5,8+i*2,x+4,18+i*2,x+1,23+i,x-1,14+i*2},c) end end)
add('Grass tuft','Herbs',18,18,herb,function(im,c) polygon(im,{7,17,2,9,0,3,4,5,8,13,8,0,11,4,10,13,16,4,18,5,12,17},c) end)
add('Small fern','Herbs',28,24,herb,function(im,c) line(im,13,23,14,1,c,1);for i=0,4 do local y=5+i*3;local reach=3+i*2;polygon(im,{13,y+2,13-reach,y-2,12-reach,y-4,14,y},c);polygon(im,{14,y+2,14+reach,y-1,15+reach,y-3,14,y},c) end end)
add('Broad herb','Herbs',22,23,herb,function(im,c) line(im,10,22,10,5,c,1);polygon(im,{10,10,4,9,0,4,1,1,7,4,10,8},c);polygon(im,{10,16,16,13,21,7,16,7,11,11},c);polygon(im,{10,19,3,17,0,12,4,12,10,16},c) end)
add('Flower stems','Herbs',18,24,herb,function(im,c) line(im,8,23,7,4,c,1);line(im,11,23,15,10,c,1);oval(im,6,3,3,2,c);oval(im,15,9,2,2,c);polygon(im,{8,17,2,13,0,9,5,11},c) end)
add('Mushroom','Details',16,16,warm,function(im,c) polygon(im,{6,15,6,8,9,8,10,15},c);polygon(im,{0,8,1,4,5,1,10,0,14,4,16,8},c) end)
add('Stone','Details',22,12,warm,function(im,c) polygon(im,{0,10,3,4,9,1,15,0,20,5,22,10,16,12,4,11},c) end)
add('Root fan','Details',36,18,wood,function(im,c) polygon(im,{13,0,22,0,24,8,34,13,36,16,22,12,19,8,15,10,10,17,6,18,11,9,1,13,0,10,10,5},c) end)
add('Nest','Details',24,12,warm,function(im,c) polygon(im,{0,2,4,4,10,5,18,4,23,1,23,6,18,10,12,12,5,10,1,6},c) end)
add('Sapling','Understory',28,40,green,function(im,c) line(im,13,39,13,7,c,2);line(im,13,22,5,15,c,1);line(im,14,15,23,7,c,1);oval(im,6,13,6,4,c);oval(im,21,7,6,5,c);oval(im,13,3,4,3,c) end)
add('Reeds','Understory',20,40,herb,function(im,c) line(im,5,39,4,4,c,1);line(im,10,39,13,1,c,1);line(im,15,39,18,12,c,1);polygon(im,{4,27,0,16,1,12,5,23},c);polygon(im,{11,30,17,21,19,18,18,25,13,33},c);oval(im,4,5,2,5,c);oval(im,13,5,2,5,c) end)
add('Climbing vine','Understory',16,40,green,function(im,c) line(im,8,39,6,26,c,1);line(im,6,26,10,12,c,1);line(im,10,12,7,0,c,1);for i=0,4 do local y=4+i*7;if i%2==0 then polygon(im,{8,y+4,1,y,0,y-2,4,y-2,9,y+1},c) else polygon(im,{8,y+4,14,y,15,y-3,11,y-2,8,y},c) end end end)
add('Bush cluster','Understory',40,24,green,function(im,c) oval(im,7,14,7,6,c);oval(im,18,8,9,8,c);oval(im,29,13,9,7,c);oval(im,19,19,14,4,c) end)
-- Species-inspired silhouettes, with both individual leaves and usable sprays.
local leafSpecs={
 {'Oak leaf',24,38,{11,0,16,2,16,6,21,6,23,10,19,14,23,16,22,21,17,23,19,28,15,31,12,34,11,37,9,37,9,33,5,30,3,26,6,23,1,20,0,16,5,14,1,10,3,6,8,7,8,3}},
 {'Maple leaf',34,34,{17,0,20,9,25,5,25,12,33,10,29,18,33,20,23,25,19,25,18,33,16,33,15,25,9,25,0,20,5,18,1,10,9,12,8,5,14,9}},
 {'Birch leaf',22,30,{11,0,14,5,18,7,17,10,21,12,19,15,22,18,18,21,18,24,13,27,12,29,10,29,9,26,5,24,4,21,0,18,3,15,1,12,5,10,4,7,8,5}},
 {'Willow leaf',10,38,{7,0,9,9,8,21,5,32,3,37,2,37,3,31,1,23,0,14,3,5}},
 {'Beech leaf',22,32,{11,0,17,5,20,11,21,18,18,24,13,28,12,31,10,31,9,28,4,25,1,20,0,13,4,6}},
 {'Alder leaf',24,30,{7,0,12,3,17,0,22,4,23,13,21,21,15,25,13,29,11,29,9,25,3,21,0,13,1,5}},
 {'Poplar leaf',26,32,{13,0,18,10,25,19,23,23,18,26,14,27,14,31,12,31,12,27,6,26,1,23,0,19,8,10}},
 {'Linden leaf',28,32,{14,0,21,7,27,13,26,20,22,24,17,25,14,29,13,31,11,30,13,25,7,27,1,22,0,15,5,8}},
 {'Ivy leaf',30,30,{14,0,18,10,29,7,25,18,28,24,19,24,16,27,15,29,13,29,13,26,8,24,0,25,4,17,0,7,11,10}},
 {'Hazel leaf',26,32,{13,0,18,4,21,7,20,10,25,12,23,16,26,19,22,23,18,26,14,27,14,31,12,31,11,27,6,26,3,23,0,19,2,16,0,12,5,10,4,7,8,4}},
 {'Elm leaf',22,34,{13,0,17,5,16,8,20,10,18,13,21,16,19,19,20,23,15,27,12,28,11,33,9,33,10,27,5,25,3,21,0,18,2,14,1,10,6,7,8,3}},
 {'Chestnut leaflet',16,42,{8,0,11,6,10,9,14,11,12,15,16,18,13,22,15,26,12,30,10,35,9,41,7,41,6,35,3,31,4,27,0,24,3,20,1,16,4,12,2,9,6,5}},
 {'Curved oak leaf',32,28,{29,0,30,5,26,8,29,12,25,15,21,12,20,18,16,20,12,17,10,23,5,24,1,27,0,25,5,21,4,16,7,12,12,14,12,8,17,7,20,9,22,3}},
 {'Side maple leaf',36,28,{0,15,10,10,8,1,18,7,22,0,26,8,34,4,32,14,36,19,27,22,25,27,18,21,13,23,12,18,1,17}},
 {'Small birch leaf',14,20,{7,0,10,5,13,8,12,11,14,13,10,16,8,17,7,19,6,19,5,17,1,14,0,10,3,6}},
 {'Small willow leaf',8,25,{5,0,7,7,6,14,4,21,2,24,1,24,2,20,0,13,1,6}}
}
for _,s in ipairs(leafSpecs) do local spec=s;add(spec[1],'Leaves',spec[2],spec[3],green,function(im,c) polygon(im,spec[4],c) end) end
local function leaflet(im,x,y,dx,dy,c)
 polygon(im,{x,y,x+dx*.35-dy*.18,y+dy*.35+dx*.18,x+dx,y+dy,x+dx*.55+dy*.18,y+dy*.55-dx*.18},c)
end
add('Ash compound leaf','Leaf sprays',36,48,green,function(im,c) line(im,17,47,17,3,c,1);leaflet(im,17,11,0,-11,c);for i=0,3 do local y=13+i*8;leaflet(im,17,y,-15,-6,c);leaflet(im,18,y+1,15,-7,c) end end)
add('Rowan compound leaf','Leaf sprays',30,44,green,function(im,c) line(im,14,43,14,2,c,1);leaflet(im,14,9,0,-9,c);for i=0,4 do local y=11+i*6;leaflet(im,14,y,-12,-4,c);leaflet(im,15,y,12,-4,c) end end)
add('Chestnut fan','Leaf sprays',48,44,green,function(im,c) local x,y=23,35;line(im,x,y,x,43,c,1);for _,d in ipairs({{-22,-14},{-16,-27},{-5,-35},{9,-33},{21,-23}}) do leaflet(im,x,y,d[1],d[2],c) end end)
add('Birch twig','Leaf sprays',42,42,green,function(im,c) line(im,5,40,30,3,c,1);for _,q in ipairs({{12,30,-10,-12},{17,23,14,-3},{22,15,-10,-13},{27,8,13,-4}}) do leaflet(im,q[1],q[2],q[3],q[4],c) end end)
add('Willow spray','Leaf sprays',44,44,green,function(im,c) line(im,0,4,39,13,c,1);for i=0,4 do local x=5+i*8;leaflet(im,x,6+i*2,(-1)^i*3,24-i,c) end end)
add('Oak spray','Leaf sprays',48,40,green,function(im,c) line(im,4,38,35,5,c,2);for _,q in ipairs({{14,27,-10,-12},{22,20,16,1},{30,11,-9,-10}}) do local x,y=q[1],q[2];leaflet(im,x,y,q[3],q[4],c);oval(im,x+math.floor(q[3]*.55),y+math.floor(q[4]*.55),5,4,c) end end)
add('Fern frond','Leaf sprays',34,48,herb,function(im,c) line(im,16,47,20,0,c,1);for i=0,7 do local y=5+i*5;local reach=3+math.floor(math.sin((i+1)/9*math.pi)*12);leaflet(im,18,y,-reach,-5,c);leaflet(im,19,y+1,reach,-5,c) end end)
add('Paired beech leaves','Leaf sprays',38,34,green,function(im,c) line(im,17,33,19,8,c,1);leaflet(im,18,18,-16,-15,c);leaflet(im,19,24,17,-18,c);leaflet(im,19,11,3,-11,c) end)
-- Modular tree kits: every branch's trunk end is on the left edge.
local function taper(im,ax,ay,bx,by,width,c)
 local n=math.max(math.abs(bx-ax),math.abs(by-ay))
 for k=0,n do local f=k/math.max(n,1);local t=math.max(1,math.floor(width*(1-f)+1));line(im,math.floor(ax+(bx-ax)*f),math.floor(ay+(by-ay)*f),math.floor(ax+(bx-ax)*f),math.floor(ay+(by-ay)*f),c,t) end
end
for _,species in ipairs({'Oak','Birch','Pine'}) do
 for mode=1,4 do local tree=species;local m=mode
  local label=({'upper branch','middle branch','lower branch','fork branch'})[m]
  add(tree..' '..label,'Branch kits',76,56,wood,function(im,c)
   local thick=tree=='Oak' and 6 or (tree=='Birch' and 3 or 4)
   local rootY=({47,28,7,43})[m];local endY=({4,15,39,17})[m]
   taper(im,0,rootY,26,math.floor((rootY+endY)/2)+3,thick,c)
   taper(im,26,math.floor((rootY+endY)/2)+3,68,endY,math.max(2,thick-2),c)
   local cy=math.floor((rootY+endY)/2)+3
   if tree=='Pine' then
    for q=0,3 do local x=28+q*11;local y=math.floor(cy+(endY-cy)*(x-26)/42)
     taper(im,x,y,x+10,y-9,2,c);taper(im,x,y,x+12,math.min(54,y+8),2,c)
    end
   else
    taper(im,25,cy,39,math.max(1,cy-20),2,c)
    taper(im,44,math.floor((cy+endY)/2),58,math.min(52,cy+10),2,c)
    line(im,55,endY+5,72,math.max(0,endY-3),c,1)
    if tree=='Birch' then line(im,34,cy-8,29,math.max(0,cy-21),c,1);line(im,58,cy+8,72,cy+4,c,1) end
   end
   if m==4 then taper(im,13,rootY-5,19,5,math.max(2,thick-2),c);taper(im,19,5,35,0,1,c) end
  end)
 end
end
local clusterSpecies={{'Oak',1},{'Birch',3},{'Maple',2},{'Willow',4},{'Beech',5},{'Pine',0}}
local function smallLeaf(im,cx,cy,index,size,angle,c)
 if index==0 then
  local r=math.floor(size*.45);polygon(im,{cx,cy-14,cx+3,cy-9,cx+2,cy-9,cx+r-2,cy-5,cx+3,cy-5,cx+r,cy,cx,cy-2,cx-r,cy,cx-3,cy-5,cx-r+2,cy-5,cx-2,cy-9,cx-3,cy-9},c)
  return
 end
 local s=leafSpecs[index];local p={};local ca,sa=math.cos(angle),math.sin(angle)
 for i=1,#s[4],2 do
  local x=(s[4][i]-s[2]/2)*size/s[3];local y=(s[4][i+1]-s[3]/2)*size/s[3]
  table.insert(p,math.floor(cx+x*ca-y*sa+.5));table.insert(p,math.floor(cy+x*sa+y*ca+.5))
 end
 polygon(im,p,c)
end
for _,spec in ipairs(clusterSpecies) do
 for density=1,2 do local name,index=spec[1],spec[2];local dense=density==1
  add(name..(dense and ' dense cluster' or ' airy cluster'),'Foliage clusters',72,52,green,function(im,c)
   -- Connected twig fans with alternate leaves, rather than floating individual icons.
   line(im,4,48,30,28,c,2);line(im,30,28,58,12,c,1)
   line(im,24,32,23,7,c,1);line(im,35,25,51,40,c,1);line(im,46,19,64,26,c,1)
   local positions={{15,35,-.9},{21,23,-.7},{23,11,-.15},{33,18,.45},{42,11,.9},{56,10,.8},{61,24,1.2},{50,37,1.4},{39,31,1.1},{29,36,.6}}
   if dense then
    for _,v in ipairs({{12,27,-.6},{17,14,-.4},{29,9,.2},{38,8,.5},{48,19,.8},{61,36,1.3},{43,43,1.1},{31,44,.7},{8,40,-.9}}) do table.insert(positions,v) end
   end
   for i,v in ipairs(positions) do smallLeaf(im,v[1],v[2],index,(dense and 15 or 12)+(i%3),v[3],c) end
  end)
 end
end
-- Retain downloaded font silhouettes when rebuilding the expanded library.
local fontManifest=io.open(dir..'/font-tree-stamps/manifest.json','r')
if fontManifest then
 local fonts=json.decode(fontManifest:read('*a'));fontManifest:close()
 for _,entry in ipairs(fonts) do local e=entry
  add(e.name,'Font tree silhouettes',e.w,e.h,green,function(im,c) im:drawImage(Image{fromFile=dir..'/font-tree-stamps/'..e.file},Point(0,0)) end)
  items[#items].glyph=e.glyph;items[#items].source=e.source
 end
end
local organicManifest=io.open(dir..'/organic-tree-stamps/manifest.json','r')
if organicManifest then
 local organic=json.decode(organicManifest:read('*a'));organicManifest:close()
 for i,e in ipairs(organic) do
  local n=i-1
  if i<=5 then e.x=(n%4)*80+math.floor((80-e.w)/2);e.y=3072+math.floor(n/4)*128+116-e.h
  else n=i-6;e.x=(n%2)*160+math.floor((160-e.w)/2);e.y=3328+math.floor(n/2)*256+240-e.h end
  e.image=Image{fromFile=dir..'/organic-tree-stamps/'..e.file};table.insert(items,e)
 end
end
local bottom=0
for _,item in ipairs(items) do bottom=math.max(bottom,item.y+item.h) end
local height=math.ceil((bottom+12)/128)*128
local original=app.open(dir..'/forest-stamps.aseprite')
local sprite=Sprite(320,height,ColorMode.RGB)
-- Preserve painted changes, shading, and layers in the existing 24-stamp master.
for i,layer in ipairs(original.layers) do
 if layer.name~='Branch and foliage clusters' then
 local dest=i==1 and sprite.layers[1] or sprite:newLayer();dest.name=layer.name;dest.opacity=layer.opacity;dest.isVisible=layer.isVisible
 local old=layer:cel(1)
 if old then local initial=dest:cel(1);if initial then sprite:deleteCel(initial) end;sprite:newCel(dest,1,Image(old.image),old.position) end
end
end
local leaves=sprite:newLayer();leaves.name='Branch and foliage clusters';leaves.stackIndex=2
local sheet=Image(320,height,ColorMode.RGB);sheet:clear()
local manifest={}
for _,item in ipairs(items) do
 if item.y>=1536 and item.y<2304 then sheet:drawImage(item.image,Point(item.x,item.y)) end
 local slice=sprite:newSlice(Rectangle(item.x,item.y,item.w,item.h));slice.name=item.name
 table.insert(manifest,{name=item.name,category=item.category,x=item.x,y=item.y,w=item.w,h=item.h,source=item.source,glyph=item.glyph,artist=item.artist,license=item.license})
end
sprite:newCel(leaves,1,sheet,Point(0,0))
sprite:saveAs(dir..'/forest-stamps.aseprite');Image(sprite):saveAs(dir..'/forest-stamps.png')
local f=io.open(dir..'/forest-stamps.json','w');f:write(json.encode(manifest));f:close()
print('Built '..#items..' editable native-pixel silhouette stamps')

