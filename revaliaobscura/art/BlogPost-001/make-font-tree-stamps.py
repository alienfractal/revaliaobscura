from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
import json
root=Path('forest-stamp-library')
dest=root/'font-tree-stamps';dest.mkdir(exist_ok=True)
font=ImageFont.truetype(str(root/'font-source/tree-icons/Tree Icons.otf'),512)
selections=[('A','Feathery conifer'),('F','Sweeping conifer'),('G','Layered broadleaf'),('H','Open branching tree'),('I','Wide round crown'),('K','Dappled crown'),('L','Asymmetric conifer'),('N','Round branch crown'),('O','Leafy sapling'),('Q','Three-lobed sapling'),('U','Dense conifer'),('Z','Compact conifer'),('c','Open conifer'),('f','Irregular branching crown'),('g','Open rounded crown'),('h','Leaning spreading tree'),('j','Tall dense conifer'),('l','Curved conifer'),('m','Broad cloud crown'),('n','Flat spreading crown'),('o','Branching leafy sapling'),('t','Narrow column tree'),('z','Tiered spreading tree'),('V','Open upright tree')]
items=[]
board=Image.new('RGB',(840,640),(29,21,37));draw=ImageDraw.Draw(board)
for i,(char,name) in enumerate(selections):
 box=font.getbbox(char)
 mask=Image.new('L',(box[2]-box[0],box[3]-box[1]),0)
 ImageDraw.Draw(mask).text((-box[0],-box[1]),char,font=font,fill=255)
 bounds=mask.getbbox();mask=mask.crop(bounds)
 mask.thumbnail((76,112),Image.Resampling.LANCZOS)
 mask=mask.point(lambda v:255 if v>=128 else 0)
 stamp=Image.new('RGBA',mask.size,(0,0,0,0));stamp.paste((108,140,80,255),(0,0,*mask.size),mask)
 filename=f'tree-{i+1:02d}.png';stamp.save(dest/filename)
 items.append(dict(name=name,category='Font tree silhouettes',w=stamp.width,h=stamp.height,file=filename,glyph=char,source='Tree Icons by Woodcutter'))
 x=i%6*140+(140-mask.width)//2;y=i//6*160+4+(112-mask.height)//2
 board.paste((199,186,142),(x,y,x+mask.width,y+mask.height),mask)
 draw.text((i%6*140+4,i//6*160+121),name,fill=(199,186,142))
 draw.text((i%6*140+4,i//6*160+140),f'{stamp.width}x{stamp.height} / {char}',fill=(199,186,142))
(dest/'manifest.json').write_text(json.dumps(items,indent=2))
board.save(root/'font-tree-silhouettes-preview.png')
print('Prepared 24 font-derived tree silhouettes with binary transparency')
