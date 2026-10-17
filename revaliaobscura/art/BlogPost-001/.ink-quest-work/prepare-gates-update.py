from pathlib import Path
import json
import hashlib

STAGE = Path(__file__).resolve().parent
REPO = STAGE.parents[2]
baseline = {p.relative_to(REPO).as_posix():hashlib.sha256(p.read_bytes()).hexdigest()
    for folder in ['lib','resources','test'] for p in (REPO/folder).rglob('*') if p.is_file()}
(STAGE/'gates-baseline.json').write_text(json.dumps(baseline))

def edit(path, old, new):
    p = STAGE/path
    text = p.read_text(encoding='utf-8')
    assert old in text, (path,old[:80])
    p.write_text(text.replace(old,new),encoding='utf-8')
def load(path): return json.loads((STAGE/path).read_text(encoding='utf-8'))
def save(path,data): (STAGE/path).write_text(json.dumps(data,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')

edit('lib/game/states/level_game/scenario/quest_locations.dart',
    "static const river = 'river_crossing';", "static const gates = 'city_gates';\n  static const river = 'river_crossing';")
edit('lib/game/states/level_game/scenario/quest_locations.dart',
    "town: 'resources/scenarios/town_square.json',", "town: 'resources/scenarios/town_square.json',\n    gates: 'resources/scenarios/city_gates.json',")
edit('lib/game/states/level_game/scenario/quest_locations.dart',
    '(from == town && to == river) ||\n        (from == river && (to == town || to == forest))',
    '(from == town && to == gates) ||\n        (from == gates && (to == town || to == river)) ||\n        (from == river && (to == gates || to == forest))')

edit('lib/game/states/level_game/view/quest_scene_entity.dart',
    "import 'dart:ui';", "import 'package:revalia/game/states/level_game/scenario/scenario_animation_config.dart';")
edit('lib/game/states/level_game/view/quest_scene_entity.dart',
    '''    return game.loadSpriteAnimation(
        asset,
        SpriteAnimationData.sequenced(
            amount: spec['frames'] as int,
            stepTime: (spec['step_time'] as num).toDouble(),
            textureSize: Vector2((spec['width'] as num).toDouble(),
                (spec['height'] as num).toDouble())));''',
    '''    final config = ScenarioAnimationConfig.fromJson(spec);
    return game.loadSpriteAnimation(asset, SpriteAnimationData([
      for (final frame in config.sequence)
        SpriteAnimationFrameData(
          srcPosition: Vector2((frame - 1) * config.width, 0),
          srcSize: Vector2(config.width, config.height),
          stepTime: config.stepTime,
        ),
    ], loop: true));''')

edit('lib/revalia_obs.dart', "import 'dart:async';", "import 'dart:async';\nimport 'package:revalia/game/states/level_game/view/city_gates_view.dart';")
edit('lib/revalia_obs.dart', 'gboard = switch (id) {',
    'gboard = switch (id) {\n      QuestLocations.gates => CityGatesView(model: model, arrivedFrom: arrivedFrom),')

p = 'lib/game/states/level_game/view/gameboard_view.dart'
edit(p, 'String? _pendingLocation;', 'String? _pendingLocation;\n  String? _dialogueTravelDestination;')
edit(p, 'void _handleDialogueEvent(String event) {', '''void _handleDialogueEvent(String event) {
    if (event == 'guard_passage') {
      _dialogueTravelDestination = QuestLocations.gates;
      return;
    }''')
edit(p, '''    super.update(dt);
    if (_pendingLocation != null)''', '''    super.update(dt);
    if (_dialogueTravelDestination != null && !(df?.isDialogActive ?? false)) {
      final destination = _dialogueTravelDestination!;
      _dialogueTravelDestination = null;
      travelTo(destination);
    }
    if (_pendingLocation != null)''')

town = load('resources/scenarios/town_square.json')
relocated = {e['interaction_id']:e for e in town['entities'] if e['interaction_id'] in ['sleeping_drunk','empty_bottle_pickup']}
town['entities'] = [e for e in town['entities'] if e['interaction_id'] not in relocated]
for e in town['entities']:
    if e['interaction_id'] == 'city_exit': e['destination'] = 'city_gates'
town['arrivals'] = {'city_gates':town['arrivals']['river_crossing']}
save('resources/scenarios/town_square.json',town)

river = load('resources/scenarios/river_crossing.json')
for e in river['entities']:
    if e['destination'] == 'town_square':
        e['destination'] = 'city_gates'
        e['interaction_id'] = 'to_gates'
        e['asset_id'] = 'placeholder:to_gates'
river['arrivals']['city_gates'] = river['arrivals'].pop('town_square')
save('resources/scenarios/river_crossing.json',river)

sequence = [1,1,1,2,3,5,6,7,5,6,7,5,6,7,1,2,3,4,5,2,2,2,2,1,2,3,4,5,6,7]
count = relocated['sleeping_drunk']
count.update(asset_id='resources/images/drunk-count-reduced-57x84-7.png',
    feet_position=[108,181],size=[32,82],
    animation={'frames':7,'width':32,'height':82,'step_time':0.2,'sequence':sequence})
bottle = relocated['empty_bottle_pickup']
bottle.update(feet_position=[135,181])
gates = {
    'id':'city_gates','background':'resources/images/RevalGates320x200-1.png',
    'perspective':{'horizon_y':90,'minimum_walkable_y':153,'minimum_scale':0.55,'maximum_scale':1.0},
    'walking_area':{'vertices':[[0,158],[320,164],[320,184],[0,181]]},
    'player':{'feet_position':[207,180],'size':[50,84]},
    'arrivals':{'town_square':[207,180],'river_crossing':[280,179]},
    'entities':[count,bottle,
      {'type':'exit','asset_id':'placeholder:to_town','interaction_id':'to_town',
       'feet_position':[42,166],'size':[46,18],'perspective_scaling':False,
       'depth_sorting':True,'destination':'town_square'},
      {'type':'exit','asset_id':'placeholder:to_river','interaction_id':'to_river',
       'feet_position':[285,168],'size':[48,18],'perspective_scaling':False,
       'depth_sorting':True,'destination':'river_crossing'}]
}
save('resources/scenarios/city_gates.json',gates)

graph = load('resources/dialogues/revalia_dialogues.json')
graph['actors']['city_guard']['entrypoints'][0]['when'] = {'all':[
    {'flag':'navigator_ink_quest_started'},{'flag':'lady_ink_directions'}]}
graph['nodes']['guard_forest']['responses'][0]['event'] = 'guard_passage'
graph['objects']['to_gates'] = {'actions':{'look':'exit_look'}}
save('resources/dialogues/revalia_dialogues.json',graph)
en = load('resources/translations/en.json')
en['dialogues']['guard_idle']['text'] = 'Keep the gate clear, traveller. If you need directions, ask someone in the square first.'
en['dialogues']['guard_forest']['text'] = 'Ink? Could not say. Try outside the walls, across the river and into the forest, if you know what to look for. You may pass.'
en['dialogues']['guard_forest']['responses']['follow_directions']['text'] = 'Thank you. I will go through the gate.'
en['messages']['sleeping_drunk_look']['text'] = 'A count, thoroughly drunk in the street beside the city gates. His bottle is empty.'
en['messages']['sleeping_drunk_talk']['text'] = '\u201c...\u00f5h... hrr... ...\u201d The count slurs something in Livonian, then loses his train of thought.'
en['messages']['empty_bottle_look']['text'] = 'An empty bottle beside the drunken count. It could hold ink.'
en['items']['empty_bottle']['look'] = 'An empty bottle from beside the drunken count at the city gates. It could hold ink.'
en['scene']['sleeping_drunk'] = 'Drunk count'
en['scene']['to_gates'] = 'To gates'
en['messages']['city_exit_locked']['text'] = 'I should speak to Hendrik, ask the lady for directions, and get the guard\'s permission first.'
save('resources/translations/en.json',en)
print('Prepared city gates, count sequence, and guard passage flow.')
