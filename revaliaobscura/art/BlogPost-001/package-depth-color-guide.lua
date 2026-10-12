local root=app.params.dir
local function readRGB(path)
 local temp=app.open(path)
 local im=Image(temp.width,temp.height,ColorMode.RGB);im:drawSprite(temp,1)
 temp:close();return im
end
local sprite=Sprite(1120,1080,ColorMode.RGB)
sprite.layers[1].name='Desk background'
local bg=Image(1120,1080,ColorMode.RGB)
bg:clear(app.pixelColor.rgba(29,21,37,255))
sprite.cels[1].image=bg
local f=io.open(root..'/layers.json','r');local layers=json.decode(f:read('*a'));f:close()
for _,entry in ipairs(layers) do
 local layer=sprite:newLayer();layer.name=entry.name
 local im=readRGB(root..'/'..entry.file)
 sprite:newCel(layer,1,im,Point(0,0))
end
local labels=sprite:newLayer();labels.name='Labels - hide when rearranging'
sprite:newCel(labels,1,readRGB(root..'/labels.png'),Point(0,0))
sprite:saveAs(root..'/forest-color-desk.aseprite')
assert(#sprite.layers==8)
local expected=app.open(root..'/forest-color-desk.png')
local a=Image(1120,1080,ColorMode.RGB);a:drawSprite(sprite,1)
local b=Image(1120,1080,ColorMode.RGB);b:drawSprite(expected,1)
a:saveAs(root..'/aseprite-preview.png')
for y=0,1079 do for x=0,1119 do
 local p,q=a:getPixel(x,y),b:getPixel(x,y)
 for _,channel in ipairs({app.pixelColor.rgbaR,app.pixelColor.rgbaG,app.pixelColor.rgbaB}) do
  assert(math.abs(channel(p)-channel(q))<=1,'Composite differs beyond text alpha rounding')
 end
end end
print('Verified: 8 editable layers; preview within 1 RGB level for text alpha rounding.')
