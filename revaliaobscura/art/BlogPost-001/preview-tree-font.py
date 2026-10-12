from PIL import Image, ImageDraw, ImageFont
from pathlib import Path
root=Path('forest-stamp-library')
font=ImageFont.truetype(str(root/'font-source/tree-icons/Tree Icons.otf'),150)
codes=list(range(65,91))+list(range(97,123))
board=Image.new('RGB',(1040,1120),(29,21,37))
draw=ImageDraw.Draw(board)
for i,code in enumerate(codes):
    char=chr(code)
    box=font.getbbox(char)
    if not box or box[2]<=box[0] or box[3]<=box[1]: continue
    mask=Image.new('L',(box[2]-box[0],box[3]-box[1]),0)
    ImageDraw.Draw(mask).text((-box[0],-box[1]),char,font=font,fill=255)
    mask.thumbnail((116,128),Image.Resampling.LANCZOS)
    mask=mask.point(lambda v:255 if v>=128 else 0)
    x=i%8*130+(130-mask.width)//2;y=i//8*160+6+(128-mask.height)//2
    board.paste((199,186,142),(x,y,x+mask.width,y+mask.height),mask)
    draw.text((i%8*130+8,i//8*160+140),f'{char} / U+{code:04X}',fill=(199,186,142))
board.save(root/'tree-font-glyph-preview.png')
print('Rendered 52 source glyph previews')
