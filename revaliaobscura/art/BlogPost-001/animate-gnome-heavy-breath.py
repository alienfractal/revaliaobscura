from pathlib import Path
from PIL import Image
import json

ROOT = Path(__file__).resolve().parent
src = Image.open(r'C:\Users\lien\Downloads\Sprite-0001.png').convert('RGBA')
EMPTY = (0, 0, 0, 0)
# Use the second, upright left-facing pose. Never resample any source pixel.
head = src.crop((34, 6, 47, 18))
torso = src.crop((35, 18, 43, 24))
legs = src.crop((36, 24, 45, 30))
brush = src.crop((27, 12, 35, 23))
# Remove the hand at the right edge of the source brush region.
for y in range(7, 11):
    brush.putpixel((7, y), EMPTY)
skin = (247, 136, 99, 255)
shade = (185, 109, 91, 255)
sleeve = (29, 21, 37, 255)

def stamp(dst, part, pos):
    dst.alpha_composite(part, pos)

def line(dst, a, b, color):
    x, y = a
    tx, ty = b
    dx, dy = abs(tx-x), -abs(ty-y)
    sx, sy = (1 if x < tx else -1), (1 if y < ty else -1)
    error = dx + dy
    while True:
        if 0 <= x < 32 and 0 <= y < 30:
            dst.putpixel((x, y), color)
        if (x, y) == (tx, ty):
            break
        e = 2 * error
        if e >= dy:
            error += dy
            x += sx
        if e <= dx:
            error += dx
            y += sy

# Brush position, head/torso translation, hand target, duration (ms).
# Breathing uses integer translation of the unmodified head, never redrawing it.
poses = [
    ((3, 6), (0, 0), (11, 13), 140, 'scrape high'),
    ((3, 8), (0, 0), (11, 15), 140, 'scrape down'),
    ((3, 12), (0, 0), (11, 19), 160, 'lower brush'),
    ((3, 18), (-1, 1), (11, 25), 200, 'set brush down'),
    ((3, 18), (0, 0), (21, 23), 280, 'release and rest'),
]
for breath in range(3):
    poses.extend([
        ((3, 18), (0, -1), (22, 22), 180, f'heavy inhale {breath+1}'),
        ((3, 18), (0, -1), (22, 22), 160, f'chest expanded {breath+1}'),
        ((3, 18), (0, 0), (21, 23), 220, f'heavy exhale {breath+1}'),
        ((3, 18), (-1, 0), (20, 23), 180, f'shoulders slump {breath+1}'),
    ])
poses.extend([
    ((3, 18), (0, 0), (14, 23), 160, 'turn attention to brush'),
    ((3, 18), (-1, 1), (12, 24), 180, 'reach down'),
    ((3, 18), (-1, 1), (11, 25), 240, 'grasp brush'),
    ((3, 15), (-1, 0), (11, 22), 160, 'pick brush off floor'),
    ((3, 12), (0, 0), (11, 19), 160, 'lift brush'),
    ((3, 8), (0, 0), (11, 15), 140, 'resume brushing'),
    ((3, 6), (0, 0), (11, 13), 140, 'scrape high loop'),
])
frames = []
metadata = []
source_palette = {p for p in src.getdata() if p[3]}
for i, (brush_pos, shift, hand, duration, action) in enumerate(poses):
    dst = Image.new('RGBA', (32, 30), EMPTY)
    sx, sy = shift
    stamp(dst, brush, brush_pos)
    stamp(dst, legs, (14, 24))
    stamp(dst, torso, (13+sx, 18+sy))
    # Close the one-pixel waist gap during inhalation, using source trouser pixels.
    if sy == -1:
        stamp(dst, legs.crop((0, 0, 7, 1)), (14, 23))
        # One additional column of original shirt pixels makes the chest expand.
        stamp(dst, torso.crop((6, 0, 7, 6)), (21+sx, 17))
    shoulder = (14+sx, 20+sy)
    elbow = (12+sx, 22+sy) if hand[1] >= 20 else (12+sx, 19+sy)
    if hand[0] >= 20:
        shoulder = (20+sx, 19+sy)
        elbow = (hand[0], 21+sy)
    line(dst, shoulder, elbow, sleeve)
    line(dst, (shoulder[0]+1, shoulder[1]), (elbow[0]+1, elbow[1]), sleeve)
    line(dst, elbow, hand, shade)
    line(dst, (elbow[0]+1, elbow[1]), (hand[0]+1, hand[1]), skin)
    head_pos = (12+sx, 6+sy)
    stamp(dst, head, head_pos)
    # Every visible head pixel must be identical to its reference pixel.
    for hy in range(head.height):
        for hx in range(head.width):
            p = head.getpixel((hx, hy))
            if p[3]:
                assert dst.getpixel((head_pos[0]+hx, head_pos[1]+hy)) == p
    assert {p for p in dst.getdata() if p[3]} <= source_palette
    frames.append(dst)
    metadata.append({'frame': i+1, 'action': action, 'duration_ms': duration,
                     'head_offset': list(head_pos)})

strip = Image.new('RGBA', (32*len(frames), 30), EMPTY)
sheet = Image.new('RGBA', (128, ((len(frames)+3)//4)*30), EMPTY)
folder = ROOT / 'gnome-heavy-breath-frames'
folder.mkdir(exist_ok=True)
for i, frame in enumerate(frames):
    strip.paste(frame, (i*32, 0))
    sheet.paste(frame, ((i%4)*32, (i//4)*30))
    frame.save(folder / f'gnome-{i+1:02d}.png')
strip.save(ROOT / 'gnome-heavy-breath-strip.png')
sheet.save(ROOT / 'gnome-heavy-breath-sheet.png')
sheet.resize((sheet.width*6, sheet.height*6), Image.Resampling.NEAREST).save(ROOT / 'gnome-heavy-breath-sheet-preview.png')
# A neutral background in the enlarged preview makes every source color visible.
preview = []
for frame in frames:
    bg = Image.new('RGBA', (32, 30), (90, 90, 90, 255))
    bg.alpha_composite(frame)
    preview.append(bg.convert('RGB').resize((256, 240), Image.Resampling.NEAREST))
preview[0].save(ROOT / 'gnome-heavy-breath-preview.gif', save_all=True,
                append_images=preview[1:], duration=[p[3] for p in poses], loop=0,
                disposal=2)
(ROOT / 'gnome-heavy-breath-timing.json').write_text(json.dumps(metadata, indent=2))
print(f'Saved {len(frames)} frames at 32 x 30. All visible head pixels identical to source; all colors from source palette.')
