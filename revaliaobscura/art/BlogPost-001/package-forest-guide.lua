local root=app.params.dir
local sprite=Sprite(320,179,ColorMode.RGB);sprite.layers[1].name='Painting passes'
local f=io.open(root..'/steps.json','r');local steps=json.decode(f:read('*a'));f:close()
for i=1,8 do
 if i>1 then sprite:newEmptyFrame() end
 local image=Image{fromFile=root..'/step-'..string.format('%02d',i)..'.png'}
 local old=sprite.layers[1]:cel(i);if old then sprite:deleteCel(old) end
 sprite:newCel(sprite.layers[1],i,image,Point(0,0))
 sprite.frames[i].duration=i==8 and 3 or 1.8
 local tag=sprite:newTag(i,i);tag.name=steps[i].title
end
local layer=sprite:newLayer();layer.name='Original reference';layer.isVisible=false
local original=Image{fromFile=root..'/step-01.png'}
for i=1,8 do sprite:newCel(layer,i,original,Point(0,0)) end
sprite:saveAs(root..'/forest-painting-study.aseprite')
for i=1,8 do
 local image=Image(320,179,ColorMode.RGB);image:drawSprite(sprite,i)
 local expected=Image{fromFile=root..'/step-'..string.format('%02d',i)..'.png'}
 -- Source PNGs can be indexed on load; compare RGB render through a temporary sprite.
 local temp=app.open(root..'/step-'..string.format('%02d',i)..'.png');local rgb=Image(320,179,ColorMode.RGB);rgb:drawSprite(temp,1)
 assert(image:isEqual(rgb),'Frame mismatch: '..i)
 temp:close()
end
print('Verified Aseprite file: 8 tagged frames; exact frame composites')
