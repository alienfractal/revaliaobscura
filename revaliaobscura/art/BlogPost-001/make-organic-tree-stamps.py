from pathlib import Path
from PIL import Image, ImageDraw, ImageChops
import json
root=Path('forest-stamp-library');dest=root/'organic-tree-stamps';dest.mkdir(exist_ok=True)
sources=[
 (244035,'Irregular woodland tree','mazeo','https://openclipart.org/detail/244035/tree-silhouette'),
 (328207,'Spreading leafy tree','GDJ','https://openclipart.org/detail/328207/highly-detailed-tree-silhouette'),
 (188718,'Gnarled bare oak','IggyOblomov','https://openclipart.org/detail/188718/oak-tree'),
 (174787,'Umbrella pine','waielbi','https://openclipart.org/detail/174787/pinus-pinea'),
 (286758,'Old broad oak','GDJ','https://openclipart.org/detail/286758/detailed-large-oak-tree-silhouette')]
masks=[]
for id,name,artist,url in sources:
 im=Image.open(root/f'organic-tree-source/{id}.png').convert('RGBA')
 darkness=ImageChops.invert(im.convert('RGB').convert('L'))
 mask=ImageChops.multiply(darkness,im.getchannel('A'))
 bounds=mask.getbbox();assert bounds,f'Empty source {id}'
 masks.append(mask.crop(bounds))
items=[]
board=Image.new('RGB',(960,680),(29,21,37));draw=ImageDraw.Draw(board)
for scale,(maxw,maxh) in enumerate([(76,112),(152,224)]):
 for i,((id,name,artist,url),source) in enumerate(zip(sources,masks)):
  mask=source.copy();mask.thumbnail((maxw,maxh),Image.Resampling.LANCZOS)
  mask=mask.point(lambda v:255 if v>=96 else 0)
  stamp=Image.new('RGBA',mask.size,(0,0,0,0));stamp.paste((108,140,80,255),(0,0,*mask.size),mask)
  filename=f'tree-{id}-'+('small' if scale==0 else 'large')+'.png';stamp.save(dest/filename)
  items.append(dict(name=name+(' small' if scale==0 else ' large'),category='Organic trees',w=stamp.width,h=stamp.height,file=filename,source=url,artist=artist,license='CC0 1.0 via Openclipart'))
  col=i%3;row=i//3;x=col*320+(320-mask.width)//2;y=row*340+5+(290-mask.height)//2
  # Main preview shows the large versions, at native size, with smaller inset sizes noted.
  if scale==1:
   board.paste((199,186,142),(x,y,x+mask.width,y+mask.height),mask)
   draw.text((col*320+12,row*340+300),name,fill=(199,186,142))
   draw.text((col*320+12,row*340+316),f'{stamp.width}x{stamp.height} px / {artist}',fill=(199,186,142))
(dest/'manifest.json').write_text(json.dumps(items,indent=2))
board.save(root/'organic-trees-preview.png')
print('Prepared five organic tree designs at two native pixel scales')

