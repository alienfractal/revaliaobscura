from pathlib import Path
from PIL import Image,ImageDraw
import json
root=Path('forest-stamp-library')
items=json.loads((root/'forest-stamps.json').read_text(encoding='utf-8-sig'))
sheet=Image.open(root/'forest-stamps.png').convert('RGBA')
out=Image.new('RGB',(1000,720),(29,21,37));draw=ImageDraw.Draw(out)
for j,n in enumerate([1,3,49,61,62,41,43,25,73,97,104,105]):
 a=items[n-1];im=sheet.crop((a['x'],a['y'],a['x']+a['w'],a['y']+a['h']))
 scale=min(3,230/a['w'],198/a['h']);im=im.resize((int(a['w']*scale),int(a['h']*scale)),Image.Resampling.NEAREST)
 x=j%4*250+(250-im.width)//2;y=j//4*240+5+(198-im.height)//2
 out.paste(im,(x,y),im)
 draw.text((j%4*250+6,j//4*240+213),a['name'],fill=(199,186,142))
out.save(root/'forest-three-color-preview.png')
assert len(items)==106 and all(a and a.get('category') for a in items)
print('Preview updated; complete 106-entry metadata')
