-- Run with --batch --script-param testload=1 --script-param dir=folder --script this-file.lua
local testDir=assert(app.params.dir,'Pass --script-param dir=path-to-script-folder')
local log=assert(io.open(app.fs.joinPath(testDir,'color-reducer-test-results.txt'),'w'))
local function stage(s) log:write(s..'\n');log:flush() end
stage('Starting')
local reduce=dofile(app.fs.joinPath(testDir,'Reduce Sprite Colors.lua'))
local pc=app.pixelColor
local function color(r,g,b,a) return Color{r=r,g=g,b=b,a=a or 255} end
local function indexed(permuted)
  local s=Sprite(8,2,ColorMode.INDEXED)
  local pal=Palette(8)
  local swatches={color(0,0,0,0),color(200,10,10),color(210,15,15),
    color(10,10,200),color(15,15,210),color(50,180,50),color(50,180,50),color(240,240,200)}
  local order=permuted and {5,7,3,0,6,2,4,1} or {0,1,2,3,4,5,6,7}
  local inverse={}
  for i,v in ipairs(order) do pal:setColor(i-1,swatches[v+1]);inverse[v]=i-1 end
  s:setPalette(pal);s.transparentColor=inverse[0]
  local im=Image(8,2,ColorMode.INDEXED)
  for y=0,1 do for x=0,7 do im:drawPixel(x,y,inverse[x]) end end
  s.cels[1].image=im
  app.sprite=s;app.frame=s.frames[1];app.layer=s.layers[1]
  app.command.NewFrame{content='cellinked'}
  s.frames[1].duration=0.17;s.frames[2].duration=0.23
  s:newTag(1,2).name='test animation'
  return s
end
local function render(s,frame)
  local im=Image(s.width,s.height,ColorMode.RGB)
  im:drawSprite(s,frame or 1)
  return im
end
local function signature(s)
  local values={}
  for p in render(s):pixels() do values[#values+1]=tostring(p()) end
  return table.concat(values,',')
end
local function checkIndexed()
  local a=indexed(false)
  local linked=a.layers[1]:cel(1).image.id==a.layers[1]:cel(2).image.id
  assert(linked,'Test fixture must have linked cels')
  local original=signature(a)
  local raw=a.cels[1].image.bytes
  local reduced,stats=reduce(a,{colors=4,copy=true,original=true})
  assert(a.cels[1].image.bytes==raw and signature(a)==original,'Original changed')
  assert(reduced.colorMode==ColorMode.INDEXED,'Lost indexed mode')
  assert(#reduced.palettes[1]<=4 and stats.entries<=4,'Palette too large')
  assert(reduced.transparentColor==0,'Mask index not normalized')
  assert((reduced.layers[1]:cel(1).image.id==reduced.layers[1]:cel(2).image.id)==linked,'Link state changed')
  assert(reduced.cels[1].image:getPixel(0,0)==0,'Transparency lost')
  for _,cel in ipairs(reduced.cels) do for p in cel.image:pixels() do
    assert(p()<#reduced.palettes[1],'Out of range index')
    if p.x>0 then assert(p()~=0,'Opaque pixel mapped to mask') end
  end end
  assert(#reduced.frames==2 and #reduced.tags==1,'Animation metadata lost')
  assert(math.abs(reduced.frames[2].duration-0.23)<0.001,'Timing changed')
  local b=indexed(true)
  local rb=reduce(b,{colors=4,copy=true,original=true})
  assert(signature(rb)==signature(reduced),'Palette index ordering affects clustering')
  local same=reduce(b,{colors=32,copy=false})
  if signature(same)~=original then
    stage('BEFORE '..original);stage('AFTER '..signature(same))
    local indices={};for p in same.cels[1].image:pixels() do indices[#indices+1]=p() end
    stage('INDICES '..table.concat(indices,','))
    for i=0,#same.palettes[1]-1 do stage('PAL '..i..' '..same.palettes[1]:getColor(i).rgbaPixel) end
  end
  assert(signature(same)==original,'No-reduction remap changed appearance')
  local before=signature(a)
  local beforeBytes=a.cels[1].image.bytes
  local beforeSize=#a.palettes[1]
  local beforeMask=a.transparentColor
  reduce(a,{colors=3,copy=false})
  app.sprite=a;app.undo()
  assert(signature(a)==before and a.cels[1].image.bytes==beforeBytes,'Undo failed')
  assert(#a.palettes[1]==beforeSize and a.transparentColor==beforeMask,'Palette/mask undo failed')
end
local function checkRgb()
  local s=Sprite(5,1,ColorMode.RGB)
  local im=Image(5,1,ColorMode.RGB)
  local src={pc.rgba(1,2,3,0),pc.rgba(200,10,10,255),pc.rgba(210,10,10,255),
    pc.rgba(0,10,200,128),pc.rgba(0,10,210,128)}
  for x=0,4 do im:drawPixel(x,0,src[x+1]) end
  s.cels[1].image=im
  local out=reduce(s,{colors=3,copy=false,original=true})
  assert(out.colorMode==ColorMode.RGB)
  for p in out.cels[1].image:pixels() do
    assert(pc.rgbaA(p())==pc.rgbaA(src[p.x+1]),'Alpha changed')
    if pc.rgbaA(p())>0 then
      local found=false
      for _,v in ipairs(src) do if p()==v then found=true end end
      assert(found,'Invented a swatch')
    end
  end
  local before=out.cels[1].image.bytes
  local ok=pcall(reduce,out,{colors=2,copy=false})
  assert(not ok and before==out.cels[1].image.bytes,'Invalid alpha budget changed sprite')
end
local function checkBackground()
  local s=indexed(true)
  app.sprite=s
  app.command.BackgroundFromLayer()
  local before=signature(s)
  reduce(s,{colors=32,copy=false})
  if signature(s)~=before then
    stage('BACKGROUND BEFORE '..before);stage('BACKGROUND AFTER '..signature(s))
  end
  assert(signature(s)==before,'Opaque background changed during mask remap')
  -- A background may also use the mask index as an ordinary opaque color.
  local s2=indexed(true)
  app.sprite=s2;app.command.BackgroundFromLayer()
  local pal=Palette(s2.palettes[1])
  pal:setColor(s2.transparentColor,color(33,44,55))
  s2:setPalette(pal)
  local original=signature(s2)
  reduce(s2,{colors=32,copy=false,original=false})
  assert(signature(s2)==original,'Background mask color became transparent')
end
local function checkHiddenAndMeans()
  local s=indexed(false)
  local hidden=s:newLayer();hidden.isVisible=false;hidden.isEditable=false
  s:newCel(hidden,1,Image(s.layers[1]:cel(1).image),Point(0,0))
  local out=reduce(s,{colors=3,copy=false,original=false,iterations=30})
  assert(not hidden.isVisible and not hidden.isEditable,'Layer properties changed')
  assert(#out.palettes[1]<=3)
  for _,cel in ipairs(out.cels) do for p in cel.image:pixels() do
    assert(p()<3,'Hidden/locked layer not remapped')
  end end
end
local ok,err=xpcall(function()
  stage('Indexed');checkIndexed();stage('RGB');checkRgb();stage('Background');checkBackground()
  stage('Hidden layers / average centers');checkHiddenAndMeans()
end,debug.traceback)
log:write(ok and 'PASS: indexed mode, index-order invariance, palette compaction, duplicate swatches, nonzero transparency, copy safety, animation, exact alpha, budget validation, background, Undo' or tostring(err))
log:close()
if not ok then error(err) end
