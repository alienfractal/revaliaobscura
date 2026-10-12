local sort= dofile(app.params.dir..'/Sort Palette by Forest Distance.lua')
local function render(s,f)
 local im=Image(s.width,s.height,ColorMode.RGB);im:drawSprite(s,f);return im
end
for _,mode in ipairs({ColorMode.INDEXED,ColorMode.RGB}) do
 for _,transparent in ipairs({0,7}) do
  local s=Sprite(16,4,mode)
  local src=app.open(app.params.source)
  local rgb=render(src,1);src:close();app.sprite=s
  local pal=Palette(64)
  for y=0,3 do for x=0,15 do pal:setColor(y*16+x,Color(rgb:getPixel(x,y))) end end
  s:setPalette(pal)
  if mode==ColorMode.INDEXED then s.transparentColor=transparent end
  local im=Image(s.cels[1].image)
  for p in im:pixels() do p(mode==ColorMode.INDEXED and (p.y*16+p.x) or rgb:getPixel(p.x,p.y)) end
  s.cels[1].image=im
  s:newEmptyFrame();s:newCel(s.layers[1],2,s.cels[1].image,Point(0,0))
  local hidden=s:newLayer();hidden.isVisible=false
  s:newCel(hidden,1,Image(im),Point(0,0))
  local before={render(s,1),render(s,2)}
  local original=s.cels[1].image.bytes
  local linked=s.layers[1]:cel(1).image.id==s.layers[1]:cel(2).image.id
  local mapping=sort(s)
  for f=1,2 do assert(before[f]:isEqual(render(s,f)),'Appearance changed') end
  assert(linked==(s.layers[1]:cel(1).image.id==s.layers[1]:cel(2).image.id),'Links changed')
  if mode==ColorMode.INDEXED then
   for p in hidden:cel(1).image:pixels() do assert(p()==mapping[p.y*16+p.x],'Hidden layer mismatch') end
   assert(s.transparentColor==transparent)
  end
  local sortedbytes=s.cels[1].image.bytes
  app.command.Undo()
  assert(s.cels[1].image.bytes==original,'Undo pixel mismatch')
  for i=0,63 do assert(s.palettes[1]:getColor(i).rgbaPixel==pal:getColor(i).rgbaPixel,'Undo palette mismatch') end
  app.command.Redo()
  assert(s.cels[1].image.bytes==sortedbytes,'Redo mismatch')
  sort(s)
  assert(s.cels[1].image.bytes==sortedbytes,'Not idempotent')
  s:close()
 end
end
print('PASS: RGB/indexed, two transparency positions, all frames, hidden cels, links, Undo/Redo, idempotence')
