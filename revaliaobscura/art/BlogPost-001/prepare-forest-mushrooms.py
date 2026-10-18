from pathlib import Path
import hashlib
import json
import os
import shutil

HERE = Path(__file__).resolve().parent
SOURCE = HERE.parent.parent
STAGE = HERE / '.forest-mushrooms-work'
assert not (STAGE / '.prepared').exists(), 'Stage already prepared; do not overwrite implementation work.'
STAGE.mkdir(exist_ok=True)
def asset_link(source, target):
    if Path(target).exists():
        assert os.path.samefile(source,target), 'Unexpected preexisting staged asset'
    else: os.link(source,target)
for name in ('lib', 'test'):
    shutil.copytree(SOURCE / name, STAGE / name, dirs_exist_ok=True)
for folder in ('images', 'audio', 'fonts', 'shaders'):
    shutil.copytree(SOURCE / 'resources' / folder, STAGE / 'resources' / folder, copy_function=asset_link, dirs_exist_ok=True)
for folder in ('scenarios', 'dialogues', 'translations'):
    shutil.copytree(SOURCE / 'resources' / folder, STAGE / 'resources' / folder, dirs_exist_ok=True)
for name in ('pubspec.yaml', 'pubspec.lock', 'analysis_options.yaml', '.metadata'):
    if (SOURCE / name).is_file(): shutil.copy2(SOURCE / name, STAGE / name)
(STAGE / '.dart_tool').mkdir(exist_ok=True)
for name in ('package_config.json', 'package_graph.json'):
    if (SOURCE / '.dart_tool' / name).is_file(): shutil.copy2(SOURCE / '.dart_tool' / name, STAGE / '.dart_tool' / name)

def read(path): return json.loads((STAGE / path).read_text(encoding='utf-8-sig'))
def write(path, data): (STAGE / path).write_text(json.dumps(data, indent=2, ensure_ascii=False)+'\n', encoding='utf-8')

scene = read('resources/scenarios/forest.json')
for e in scene['entities']:
    if e['interaction_id'] == 'forest_mushroom':
        e.update(asset_id='resources/images/forest-mushroom-2-sheet_88x128-19.png',
                 feet_position=[267,173],size=[44,64],
                 animation={'frames':19,'width':88,'height':128,'step_time':0.14},
                 talk_asset='resources/images/forest-mushroom-2-sheet_88x128-19.png',
                 talk_animation={'frames':19,'width':88,'height':128,'step_time':0.10})
    elif e['interaction_id'] == 'inkcap':
        e.update(asset_id='resources/images/forest-mushroom-talk-purple-sheet_50x52-10.png',
                 feet_position=[300,175],size=[25,26],
                 animation={'frames':10,'width':50,'height':52,'step_time':0.14})
scene['entities'].insert(-1,{
    'type':'quest_prop','asset_id':'resources/images/00054-mush3-sheet_32x51-9.png',
    'interaction_id':'knife_mushroom','dialogue_actor_id':'knife_mushroom',
    'feet_position':[88,175],'size':[32,51],
    'perspective_scaling':False,'depth_sorting':True,
    'animation':{'frames':9,'width':32,'height':51,'step_time':0.16},
    'attack_animation':{'frames':9,'width':32,'height':51,'step_time':0.08}
})
write('resources/scenarios/forest.json',scene)

g=read('resources/dialogues/revalia_dialogues.json')
g['actors']['knife_mushroom']={
    'id':'knife_mushroom','name_key':'actors.knife_mushroom.name',
    'actions':{'look':'knife_mushroom_look','touch':'knife_mushroom_touch'},
    'entrypoints':[{'dialogue':'knife_mushroom_intro'}]
}
g['actors']['forest_mushroom']['entrypoints']=[
    {'dialogue':'wise_mushroom_after_ink','when':{'flag':'forest_ink_collected'}},
    {'dialogue':'wise_mushroom_intro'}
]
g['actors']['inkcap']['entrypoints']=[{'dialogue':'purple_mushroom_silent'}]
g['nodes'].update({
    'knife_mushroom_intro':{'responses':[
        {'id':'yes','next':'end','event':'player_death'},
        {'id':'no','next':'knife_mushroom_relief'},
        {'id':'leave','next':'end'}]},
    'knife_mushroom_relief':{'responses':[{'id':'leave','next':'end'}]},
    'wise_mushroom_intro':{'responses':[
        {'id':'ask_metsavana','next':'wise_mushroom_metsavana'},
        {'id':'ask_ink','next':'wise_mushroom_ink'},
        {'id':'ask_knife','next':'wise_mushroom_knife'},
        {'id':'leave','next':'end'}]},
    'wise_mushroom_metsavana':{'responses':[
        {'id':'ask_gnomes','next':'wise_mushroom_gnomes'},
        {'id':'back','next':'wise_mushroom_intro'}]},
    'wise_mushroom_gnomes':{'responses':[{'id':'back','next':'wise_mushroom_intro'}]},
    'wise_mushroom_ink':{'responses':[{'id':'leave','next':'end'}]},
    'wise_mushroom_knife':{'responses':[{'id':'back','next':'wise_mushroom_intro'}]},
    'wise_mushroom_after_ink':{'responses':[
        {'id':'ask_metsavana','next':'wise_mushroom_metsavana'},
        {'id':'leave','next':'end'}]},
    'purple_mushroom_silent':{'responses':[{'id':'leave','next':'end'}]}
})
for name in ('knife_mushroom_look','knife_mushroom_touch','inkcap_collected','inkcap_already_collected'):
    g['messages'][name]={}
write('resources/dialogues/revalia_dialogues.json',g)

manifest={}
for path in [p.relative_to(STAGE) for p in (STAGE/'lib').rglob('*.dart')]+[p.relative_to(STAGE) for p in (STAGE/'test').rglob('*.dart')]+[p.relative_to(STAGE) for p in (STAGE/'resources').rglob('*.json')]:
    original=SOURCE/path
    if original.is_file(): manifest[path.as_posix()]=hashlib.sha256(original.read_bytes()).hexdigest()
(HERE/'forest-mushrooms-before-hashes.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
(STAGE / '.prepared').write_text('Original game files are read-only inputs; apply only reviewed changed files.',encoding='utf-8')
print('Prepared isolated forest-mushroom implementation and test workspace.')
