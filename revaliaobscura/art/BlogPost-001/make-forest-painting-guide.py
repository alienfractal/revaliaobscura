from pathlib import Path
from PIL import Image,ImageDraw,ImageFont,ImageFilter
import json,math
root=Path('forest-painting-guide');root.mkdir(exist_ok=True)
source=Image.open('../forest background-v2.png').convert('RGB')
reference=Image.open('../ChatGPT Image Oct 12, 2026, 01_54_54 PM.png').convert('RGB')
size=source.size
palette=list(dict.fromkeys([p for p in Image.open('revalia.png').convert('RGBA').getdata() if p[3]==255]))
palette=[p[:3] for p in palette]
cache={}
def closest(c):
 if c not in cache:cache[c]=min(palette,key=lambda p:2*(c[0]-p[0])**2+4*(c[1]-p[1])**2+3*(c[2]-p[2])**2)
 return cache[c]
def indexed_rgb(im):
 out=Image.new('RGB',im.size);out.putdata([closest(p) for p in im.getdata()]);return out
target=indexed_rgb(indexed_rgb(reference.resize(size,Image.Resampling.BOX)).filter(ImageFilter.ModeFilter(3)))
coarse=target.filter(ImageFilter.ModeFilter(5))
initial=indexed_rgb(source)
def wood(p):return p[0]>p[1]*1.13 and p[0]>p[2]*.96
def foliage(p):return p[1]>p[0]*1.08 and p[1]>p[2]*1.06
woodDark=(39,20,23);woodMid=(78,40,46);woodLit=(117,66,62)
leafDark=(27,58,47);leafMid=(43,103,78);leafLight=(108,140,80)
farDark=(39,43,55);farMid=(61,67,86);farLight=(79,109,111)
# Construct a limited-color block-in of the actual reference, not a dissolve.
block=Image.new('RGB',size)
for y in range(size[1]):
 for x in range(size[0]):
  p=coarse.getpixel((x,y));lum=sum(p)/3
  if wood(p):c=woodMid
  elif foliage(p):c=leafDark if lum<48 else leafMid
  else:c=farDark if lum<39 else (farMid if lum<72 else farLight)
  block.putpixel((x,y),c)
# Frame 2 groups the existing background and ground while retaining its silhouettes.
valueStudy=Image.new('RGB',size)
for y in range(size[1]):
 for x in range(size[0]):
  p=initial.getpixel((x,y));lum=sum(p)/3
  if y>size[1]*.80:c=woodDark if wood(p) else leafDark
  elif wood(p):c=woodMid if lum>40 else woodDark
  elif foliage(p):c=leafMid if lum>75 else leafDark
  else:c=farMid if lum<93 else farLight
  valueStudy.putpixel((x,y),c)
# Preserve the student's composition while first adding depth behind its nearest trees.
depthStudy=valueStudy.copy()
for y in range(size[1]):
 for x in range(size[0]):
  p=initial.getpixel((x,y))
  if not wood(p) and not foliage(p) and y<size[1]*.80:
   depthStudy.putpixel((x,y),block.getpixel((x,y)))
# Complete the reference-derived shape rebuild without texture.
steps=[source,valueStudy,depthStudy,block]
distance=block.copy()
for y in range(size[1]):
 for x in range(size[0]):
  p=target.getpixel((x,y))
  if not wood(p) and not foliage(p):distance.putpixel((x,y),p)
steps.append(distance)
bark=distance.copy()
for y in range(size[1]):
 for x in range(size[0]):
  p=target.getpixel((x,y))
  if wood(p):bark.putpixel((x,y),p)
steps.append(bark)
leaves=bark.copy()
for y in range(size[1]):
 for x in range(size[0]):
  p=target.getpixel((x,y))
  if foliage(p):leaves.putpixel((x,y),leafLight if sum(p)/3>85 else p)
steps.append(leaves)
steps.append(target)
titles=['01 Your original','02 Group values','03 Build distant depth','04 Rebuild large shapes','05 Refine distant trees','06 Shade trunks and ground','07 Shade foliage masses','08 Restrained highlights']
notes=[
 'Your untouched 320x179 drawing. Keep a duplicate before experimenting.',
 'Reduce the ground to broad shapes, mute the purple grass strip, and separate cool distant trees from warm near trunks. Texture can wait.',
 'Place faint, overlapping tree shapes behind the existing foreground trunks. Work on a background layer; keep the near silhouettes visible.',
 'Repaint larger tapering trunks and asymmetric branches. Block foliage as masses. This is the largest composition change: a reference study, not a hidden automatic cleanup.',
 'Add variation to far tree edges. Their small value differences should stay quieter than foreground shapes. Avoid outlining every distant tree.',
 'Use broad shadow planes and a few broken vertical bark marks. Give the forest floor a continuous base instead of repeating bright plants everywhere.',
 'Shade leaf masses with dark interiors and small lit clusters. Place clusters around branch tips, varying their density and leaving irregular gaps.',
 'Use sparse olive highlights on leaf tops, herbs, and the ground edge. The final frame is the supplied reference resized, mapped to the game palette, and simplified to reduce isolated texture pixels.'
]
for i,im in enumerate(steps):im.save(root/f'step-{i+1:02d}.png')
# View enlarged nearest-neighbor art, not a smoothed preview.
cellW,cellH=680,442
board=Image.new('RGB',(cellW*2,cellH*4),(29,21,37));draw=ImageDraw.Draw(board)
try:font=ImageFont.truetype('C:/Windows/Fonts/consola.ttf',19)
except OSError:font=ImageFont.load_default()
for i,im in enumerate(steps):
 x=(i%2)*cellW+20;y=(i//2)*cellH+12
 draw.text((x,y),titles[i],fill=(241,233,205),font=font)
 board.paste(im.resize((640,358),Image.Resampling.NEAREST),(x,y+34))
 draw.text((x,y+399),f'Native {size[0]} x {size[1]} pixels',fill=(199,186,142),font=font)
board.save(root/'forest-painting-sequence.png')
# A slideshow, not a crossfade; each frame is a different paint pass.
large=[im.resize((640,358),Image.Resampling.NEAREST) for im in steps]
large[0].save(root/'forest-painting-sequence.gif',save_all=True,append_images=large[1:],duration=[1800]*7+[3000],loop=0,disposal=2)
(root/'steps.json').write_text(json.dumps([dict(title=t,note=n) for t,n in zip(titles,notes)],indent=2))
guide='# Forest painting study\n\nThis is a teaching reconstruction from your drawing toward the supplied reference. These are reference-derived paint passes, not a record of manual painting. The source PNG is untouched. All frames are 320x179. Frame 1 keeps your original colors; subsequent frames use only revalia.png.\n\n'
guide+='The reference is an AI illustration shown at a larger size. At native game scale, fine leaves and bark become much smaller clusters. Judge your result at 100% and at a nearest-neighbor zoom.\n\n'
for t,n in zip(titles,notes):guide+=f'## {t}\n\n{n}\n\n'
guide+='## How to practice in Aseprite\n\nUse the sequence as reference rather than tracing all the texture. Make separate working layers for distant forest, foreground trunks, foliage, floor, and highlights. Complete the block-in before painting small leaves. On each layer, use two or three tones, keep a consistent upper-left light, and test the 50x85 character against the scene.\n\nThe animation has a named tag for each step. Hide the optional Original reference layer during normal viewing; it is provided for comparison.\n'
(root/'PAINTING-GUIDE.md').write_text(guide)
assert steps[0].tobytes()==source.tobytes()
assert all(im.size==size for im in steps)
allowed=set(palette)
assert all(set(im.getdata())<=allowed for im in steps[1:])
print('Saved 8 distinct painting-study frames, 320x179, palette verified; original unchanged')



