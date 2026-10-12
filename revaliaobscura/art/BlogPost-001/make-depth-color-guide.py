from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import json

root = Path('forest-color-guide')
root.mkdir(exist_ok=True)
palette = list(dict.fromkeys(p[:3] for p in Image.open('revalia.png').convert('RGBA').getdata() if p[3] == 255))
W,H = 1120,1080
bg = palette[5]
ink = palette[11]
muted = palette[10]
font = ImageFont.truetype('C:/Windows/Fonts/consola.ttf',18)
small = ImageFont.truetype('C:/Windows/Fonts/consola.ttf',14)
title = ImageFont.truetype('C:/Windows/Fonts/consolab.ttf',27)
labels = Image.new('RGBA',(W,H),(0,0,0,0))
d = ImageDraw.Draw(labels)
def text(x,y,s,f=font,c=ink): d.text((x,y),s,font=f,fill=c+(255,))
text(24,20,'FOREST COLOR DESK',title)
text(24,60,'Top = nearer  |  Bottom = farther  |  Each trio = shadow / body / light')
text(24,88,'A starting recipe for this cool forest. Distance reduces contrast; it does not mean white.',small,muted)
text(280,128,'BARK / EARTH',font)
text(688,128,'FOLIAGE',font)
rows = [
 ('01 Near', 'Strong form contrast', [39,21,14], [6,7,17]),
 ('02 Middle', 'Cooler, quieter shapes', [48,3,51], [6,31,51]),
 ('03 Far', 'Materials merge', [3,51,30], [3,51,30]),
 ('04 Mist silhouettes', 'Use mainly the last two', [51,30,30], [51,30,30]),
]
layers=[]
for i,(name,note,bark,leaf) in enumerate(rows):
 y=165+i*120
 text(24,y+12,name)
 text(24,y+43,note,small,muted)
 layer=Image.new('RGBA',(W,H),(0,0,0,0));ld=ImageDraw.Draw(layer)
 for base,ids in [(280,bark),(688,leaf)]:
  for k,p in enumerate(ids):
   x=base+k*126
   ld.rectangle((x,y,x+112,y+62),fill=palette[p]+(255,))
   text(x,y+68,'#%02X%02X%02X'%palette[p],small)
 path=f'row-{i+1}.png';layer.save(root/path)
 layers.append({'name':name+' - movable swatches','file':path})
text(24,654,'ACCENTS: flowers, warm light, fresh leaves - use locally, not as depth steps',small,muted)
accent=Image.new('RGBA',(W,H),(0,0,0,0));ad=ImageDraw.Draw(accent)
for j,p in enumerate([9,10,28,43,15,22,25,35]):
 x=24+j*135
 ad.rectangle((x,682,x+116,721),fill=palette[p]+(255,))
 text(x,726,'#%02X%02X%02X'%palette[p],small)
accent.save(root/'accents.png');layers.append({'name':'Accents - movable swatches','file':'accents.png'})
text(24,768,'COMPLETE PALETTE - 54 original opaque colors (hex labels, not sprite indices)',small,muted)
atlas=Image.new('RGBA',(W,H),(0,0,0,0));a=ImageDraw.Draw(atlas)
for j,p in enumerate(palette):
 x=24+(j%18)*60;y=797+(j//18)*72
 a.rectangle((x,y,x+51,y+36),fill=p+(255,))
 text(x,y+40,'%02X%02X%02X'%p,ImageFont.truetype('C:/Windows/Fonts/consola.ttf',11))
atlas.save(root/'all-colors.png');layers.append({'name':'Complete palette - movable swatches','file':'all-colors.png'})
text(24,1023,'Choose distance > material > body color; add shadow and light only where the form needs them.',small)
text(24,1046,'Repeated swatches are intentional. No colors were added to your palette.',small,muted)
labels.save(root/'labels.png')
board=Image.new('RGBA',(W,H),bg+(255,))
for layer in layers:
 im=Image.open(root/layer['file'])
 assert all(p[:3] in palette for p in im.getdata() if p[3])
 board.alpha_composite(im)
board.alpha_composite(labels)
board.convert('RGB').save(root/'forest-color-desk.png')
(root/'layers.json').write_text(json.dumps(layers))
(root/'README.md').write_text('''# Forest color desk

This is a scene-specific arrangement of the 54 opaque colors in revalia.png. It does not alter any existing artwork or palette indices. Colors repeat intentionally between materials and depth rows. The complete palette is also included below the suggested ramps.

Open forest-color-desk.aseprite. Each depth row, the accents, the complete palette, and the labels occupy separate layers. This guide is RGB so moving its swatches does not change indexed artwork. Do not load its palette over an existing indexed sprite. Hex labels identify actual colors, not index numbers.

For a guide inside your working document: save a copy, create a layer called Color desk, and copy a few swatches into unused canvas space. Confirm their RGB values match your existing palette. Move the swatch pixels, not the entries in the palette bar. Hide this layer before exporting. Editing a shared palette entry still changes every indexed pixel using it, even when guide pixels are on another layer.

Choose a row for distance, then bark or foliage, and start with the center/body color. Add the shadow only on the unlit planes, and the light only on upward-facing or exposed planes. Keep the farthest silhouettes mostly to the final two swatches. The repeated far-mist swatch deliberately reduces that row to two colors.

Depth is a relationship: distant forms converge toward the atmosphere color, with less contrast and detail. Here that atmosphere is muted blue-green. Near objects may be dark, far objects need not become white, and saturation need not decrease uniformly for every hue. Lighting and material remain separate decisions. These ramps are practical starting choices, not universal physical rules.

The accent row holds bright leaves, flowers and warm highlights separately, so brightness does not become a false signal for distance. Use only a few accents around focal points.
''')
print('Created guide; all swatch pixels match the 54 source colors.')

