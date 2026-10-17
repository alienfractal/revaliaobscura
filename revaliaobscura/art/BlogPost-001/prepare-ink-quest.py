from pathlib import Path
import json
import shutil

ROOT = Path(__file__).resolve().parent
STAGE = ROOT / '.ink-quest-work'

def edit(path, old, new):
    p = STAGE / path
    text = p.read_text(encoding='utf-8')
    assert old in text, (path, old[:70])
    p.write_text(text.replace(old, new), encoding='utf-8')

def save(path, data):
    (STAGE / path).write_text(json.dumps(data, indent=2, ensure_ascii=False)+'\n', encoding='utf-8')

p = 'lib/game/states/level_game/scenario/scenario_config.dart'
edit(p, 'required this.entities,', 'required this.entities,\n    this.arrivals = const {},')
edit(p, "id: _string(json, 'id'),", "arrivals: (json['arrivals'] as Map<String, dynamic>? ?? {}).map((id, point) => MapEntry(id, _vector(point, 'arrivals.$id'))),\n      id: _string(json, 'id'),")
edit(p, 'final String id;', 'final Map<String, Vector2> arrivals;\n  final String id;')
edit(p, 'required this.sortsWithDepth,', 'required this.sortsWithDepth,\n    this.destination, this.animation, this.talkAsset, this.talkAnimation,')
edit(p, "type: _string(json, 'type'),", "destination: json['destination'] as String?,\n      animation: json['animation'] as Map<String, dynamic>?,\n      talkAsset: json['talk_asset'] as String?,\n      talkAnimation: json['talk_animation'] as Map<String, dynamic>?,\n      type: _string(json, 'type'),")
edit(p, 'final String type;', 'final String? destination;\n  final Map<String, dynamic>? animation;\n  final String? talkAsset;\n  final Map<String, dynamic>? talkAnimation;\n  final String type;')

p = 'lib/dialoguefsm/adventure_state.dart'
edit(p, 'final Map<String, int> requiredItems;', 'final Map<String, int> requiredItems;\n  final Map<String, int> rewards;')
edit(p, 'this.requiredItems);', 'this.requiredItems, [this.rewards = const {}]);')
edit(p, '_quests[entry.key] = QuestDefinition(', '''final rewards = (data['rewards'] as Map<String, dynamic>? ?? {})
          .map((id, quantity) => MapEntry(id, quantity as int));
      for (final reward in rewards.entries) {
        if (!_items.containsKey(reward.key) || reward.value <= 0) {
          throw FormatException('Invalid reward for quest ${entry.key}');
        }
      }
      _quests[entry.key] = QuestDefinition(''')
edit(p, 'Map.unmodifiable(required));', 'Map.unmodifiable(required), Map.unmodifiable(rewards));')
edit(p, '_completed.add(questId);', '''_completed.add(questId);
    for (final reward in quest.rewards.entries) {
      addItem(reward.key, reward.value);
    }''')

p = 'lib/dialoguefsm/story_state.dart'
edit(p, "final item = effect['add_item'] as String?;", '''final removed = effect['remove_item'] as String?;
      if (removed != null) {
        if (!adventure.removeItem(removed, effect['quantity'] as int? ?? 1)) {
          throw StateError('Cannot consume item: $removed');
        }
        continue;
      }
      final item = effect['add_item'] as String?;''')

# Recheck conditions at selection time: an old UI response cannot award ink twice.
p = 'lib/dialoguefsm/dialogue_fsm.dart'
edit(p, 'final response = dialogue.responses[index];', '''final response = dialogue.responses[index];
    if (activeSession?.currentNodeId != dialogue.id) {
      throw StateError('This dialogue is no longer active.');
    }
    final rawResponses = (_graphNodes[dialogue.id] as Map<String, dynamic>)['responses'] as List<dynamic>;
    final raw = rawResponses.cast<Map<String, dynamic>>().firstWhere((r) => r['id'] == response.id);
    if (!storyState.matches(raw['when'] as Map<String, dynamic>?) ||
        (response.once && storyState.isResponseConsumed(_responseStateId(dialogue.id, response.id)))) {
      throw StateError('This response is no longer available.');
    }''')

p = 'lib/game/states/level_game/view/female_clothes_trader_npc_entity.dart'
edit(p, 'required super.interactionId,', 'required super.interactionId,\n    super.dialogueActorId,')
p = 'lib/game/states/level_game/view/level_entity.dart'
edit(p, 'bool get canTalk => dialogueActorId != null;', 'bool get canTalk => dialogueActorId != null &&\n      DialogueManager.canStartConversation(dialogueActorId!);')
edit(p, 'final behaviour = _actionBehaviourFor(actionType);', '''if (game.gboard.handleQuestAction(this, actionType)) return;
    final behaviour = _actionBehaviourFor(actionType);''')

p = 'lib/game/states/level_game/view/market_background_entity.dart'
edit(p, 'void onLoad() {\n    super.onLoad();', 'Future<void> onLoad() async {\n    await super.onLoad();')
edit(p, '''default:
        throw ArgumentError.value(
          backgroundId,
          'backgroundId',
          'Unknown scenario background ID',
        );''', '''default:
        add(SpriteComponent(sprite: await game.loadSprite(backgroundId),
          size: size.clone(), paint: Paint()..filterQuality = FilterQuality.none));
        return;''')
edit(p, "import 'package:flame/components.dart';", "import 'dart:ui';\nimport 'package:flame/components.dart';")

p = 'lib/game/states/level_game/view/gameboard_view.dart'
edit(p, "import 'dart:async';", "import 'dart:async';\nimport 'dart:ui';\nimport 'package:flame/text.dart';\nimport 'package:flutter/painting.dart';\nimport 'package:revalia/dialoguefsm/adventure_state.dart';\nimport 'package:revalia/game/states/level_game/scenario/quest_locations.dart';\nimport 'package:revalia/game/states/level_game/view/quest_scene_entity.dart';")
edit(p, 'late GameBoardModel gBoardModel;', '''final String locationId;
  final String? arrivedFrom;
  bool _travelRequested = false;
  bool _poisoning = false;
  bool _retryPoisoningRequested = false;
  double _poisonSeconds = 0;
  int? _scorePopupPoints;
  String? _pendingLocation;
  late GameBoardModel gBoardModel;''')
edit(p, 'GameboardView({GameBoardModel? model}) {', "GameboardView({GameBoardModel? model, this.locationId = QuestLocations.town, this.arrivedFrom}) {")
edit(p, "'resources/scenarios/town_square.json',", 'QuestLocations.paths[locationId]!,')
edit(p, 'void _handleDialogueEvent(String event) {', '''void _handleDialogueEvent(String event) {
    if (event == 'mushroom_poisoning') {
      // Defer until the response handler has closed the dialogue frame.
      _poisoning = true;
      _poisonSeconds = 0;
      return;
    }
    if (event == 'conversation_end' &&
        DialogueManager.fsm.storyState.adventure.status('navigator_ink') == QuestStatus.completed) {
      _awardQuestCompletion();
    }''')
edit(p, 'uiGameBoardComponents.flashScoreChange();', '''uiGameBoardComponents.flashScoreChange();
          _scorePopupPoints = points;''')
edit(p, '''    super.update(dt);
    if (_scoreTransitionRequested)''', '''    super.update(dt);
    if (_pendingLocation != null) {
      final next = _pendingLocation!;
      _pendingLocation = null;
      game.openLocation(next, arrivedFrom: locationId);
      return;
    }
    if (_retryPoisoningRequested) {
      _retryPoisoningRequested = false;
      game.openLocation(QuestLocations.forest);
      return;
    }
    if (_scorePopupPoints != null) {
      final points = _scorePopupPoints!;
      _scorePopupPoints = null;
      final popup = TextComponent(text: '+$points', position: Vector2(40, 30),
        priority: 3000, textRenderer: TextPaint(style: const TextStyle(
          fontFamily: 'scumm', fontSize: 12, color: Color(0xffffdb69))));
      add(popup);
      popup.add(TimerComponent(period: 2, removeOnFinish: true,
        onTick: popup.removeFromParent));
    }
    if (_poisoning) {
      _updatePoisoning(dt);
      return;
    }
    if (_scoreTransitionRequested)''')
# The adventure demo has no time limit: the old 30-second timer would end exploration.
edit(p, 'if (clickCount > 2) {', 'if (false) { // Exploration does not consume the legacy combat timer.')
edit(p, 'addPlayer(scenario.player);', '''final arrival = scenario.arrivals[arrivedFrom];
    addPlayer(arrival == null ? scenario.player : ScenarioPlayerConfig(
      feetPosition: arrival, size: scenario.player.size));''')
edit(p, "case 'static_prop':", "case 'quest_prop':\n      case 'exit':\n        entity = QuestSceneEntity(config);\n      case 'static_prop':")
edit(p, "case 'female_clothes_trader':\n            entity = FemaleClothesTraderNpcEntity(", "case 'female_clothes_trader':\n            entity = FemaleClothesTraderNpcEntity(\n              dialogueActorId: config.dialogueActorId,")
edit(p, 'void callRenderDialogue(LevelEntity actorEntity) {', '''void travelTo(String destination) {
    if (_travelRequested || isGameFinished || (df?.isDialogActive ?? false)) return;
    if (!QuestLocations.canTravel(locationId, destination,
        gateUnlocked: DialogueManager.fsm.storyState.flag('city_exit_unlocked'))) {
      showScreenMessage(adventureText('messages.city_exit_locked.text'));
      return;
    }
    _travelRequested = true;
    playerEntity.cancelMovement();
    playerEntity.disableActions();
    closeInventory();
    selectedInventoryItem = null;
    _pendingLocation = destination;
  }

  bool handleQuestAction(LevelEntity target, ActionableType action) {
    if (target.interactionId == 'metsavana' && action == ActionableType.talk) {
      showScreenMessage(adventureText('messages.metsavana_silent.text'));
      return true;
    }
    return false;
  }

  void _awardQuestCompletion() {
    _handleDialogueEvent('score_milestone:deliver_hendrik_ink:500');
  }

  void _updatePoisoning(double dt) {
    if (_poisonSeconds == 0) {
      removeDialogFrame();
      isGameFinished = true;
      playerEntity.cancelMovement();
      playerEntity.disableActions();
      playerEntity.playerAnimationHandler.spriteAnimationComponent.paint.colorFilter =
        const ColorFilter.mode(Color(0xff59bb45), BlendMode.modulate);
      game.ap.playSoundFx(Assets.resources.audio.death);
    }
    _poisonSeconds += dt;
    if (_poisonSeconds < 1.0) return;
    _poisoning = false;
    playerEntity.playerAnimationHandler.triggerDie(onComplete: () {
      if (!isMounted) return;
      showScreenMessage(adventureText('messages.mushroom_poisoned.text'),
        durationSeconds: null, onDismissed: () {
          if (isMounted) _retryPoisoningRequested = true;
        });
    });
  }

  void callRenderDialogue(LevelEntity actorEntity) {''')
# Inventory delivery also grants the quest-defined map and celebrates once.
edit(p, "showScreenMessage(quest == null", "if (quest != null) _awardQuestCompletion();\n    if (quest == null) selectedInventoryItem = item;\n    showScreenMessage(quest == null")

p = 'lib/revalia_obs.dart'
edit(p, "import 'dart:async';", "import 'dart:async';\nimport 'package:revalia/game/states/level_game/view/river_crossing_view.dart';\nimport 'package:revalia/game/states/level_game/view/forest_view.dart';\nimport 'package:revalia/game/states/level_game/scenario/quest_locations.dart';")
edit(p, 'void loadFreshGameboard() {', '''void openLocation(String id, {String? arrivedFrom}) {
    final model = gboard.gBoardModel;
    gboard = switch (id) {
      QuestLocations.river => RiverCrossingView(model: model, arrivedFrom: arrivedFrom),
      QuestLocations.forest => ForestView(model: model, arrivedFrom: arrivedFrom),
      QuestLocations.town => GameboardView(model: model, arrivedFrom: arrivedFrom),
      _ => throw ArgumentError.value(id, 'id', 'Unknown location'),
    };
    cam.stop();
    cam.viewfinder.position = Vector2.zero();
    switchToWorld(gboard);
  }

  void loadFreshGameboard() {''')

graph = json.loads((STAGE/'resources/dialogues/revalia_dialogues.json').read_text())
en = json.loads((STAGE/'resources/translations/en.json').read_text())

def actor(id, entries, actions=None):
    graph['actors'][id] = {'id': id, 'name_key': f'actors.{id}.name',
                           'actions': actions or {}, 'entrypoints': entries}

def flag(id): return {'flag': id}
def quest(status): return {'quest':'navigator_ink', 'status':status}
def response(id, next='end', **kwargs): return dict(id=id, next=next, **kwargs)
def node(id, player, text, replies):
    graph['nodes'][id] = {'responses': [r[0] for r in replies]}
    en['dialogues'][id] = {'player_text':player, 'text':text,
                           'responses':{r[0]['id']:{'text':r[1]} for r in replies}}
def message(id, text):
    graph['messages'][id] = {}
    en['messages'][id] = {'text':text}

actor('female_clothes_trader', [
    {'dialogue':'lady_after_ink', 'when':quest('completed')},
    {'dialogue':'lady_directions', 'when':flag('lady_ink_directions')},
    {'dialogue':'lady_hendrik', 'when':flag('navigator_ink_quest_started')}
], graph['objects']['female_clothes_trader']['actions'])
actor('city_guard', [{'dialogue':'guard_forest', 'when':flag('navigator_ink_quest_started')},
                     {'dialogue':'guard_idle'}], {'look':'city_guard_look'})
actor('forest_mushroom', [
    {'dialogue':'mushroom_collected', 'when':flag('forest_ink_collected')},
    {'dialogue':'mushroom_ink', 'when':flag('navigator_ink_quest_started')},
    {'dialogue':'mushroom_idle'}], {'look':'mushroom_look'})
node('lady_hendrik', 'Excuse me.', 'Oh, I see you got acquainted with Hendrik. What did he tell you?', [
    (response('explain_ink', 'lady_directions', effects=[{'set_flag':'lady_ink_directions'}]),
     'He needs ink. I am new here; where should I look?'),
    (response('leave'), 'Perhaps another time.')])
node('lady_directions', 'Hendrik sent me to find ink.',
     'Ink is expensive here. Try asking the guard by the city gate. He might know where to look.', [
    (response('thank_lady'), 'Thank you. I will ask him.')])
node('lady_after_ink', 'I found ink for Hendrik.', 'Then you are finding your way around already.', [
    (response('leave'), 'Thanks for your help.')])
node('guard_idle', 'Good day.', 'Keep the gate clear, traveller.', [(response('leave'), 'Of course.')])
node('guard_forest', 'Where can I find ink around here?',
     'Could not say. You might try outside the gates, across the river and into the forest, if you know what to look for. That is all I can tell you.', [
    (response('follow_directions', effects=[{'set_flag':'city_exit_unlocked'}]), 'I will try the forest.'),
    (response('leave'), 'I will think about it.')])
node('mushroom_idle', 'Did you just move?', 'Everything in this forest moves eventually.', [(response('leave'), 'Right...')])
collect_when = {'all':[flag('navigator_ink_quest_started'), {'has_item':'empty_bottle'},
                       {'not':flag('forest_ink_collected')}]}
node('mushroom_ink', 'I need black ink. Does the big fellow know where to find it?',
     'Metsavana is busy. I do the talking. See that inkcap beside me? Its black goo is ready to write with. You could bottle it. Or perhaps you were thinking of licking it?', [
    (response('collect_ink', 'mushroom_collected', when=collect_when, once=True, effects=[
        {'remove_item':'empty_bottle'}, {'add_item':'ink_bottle'},
        {'set_flag':'forest_ink_collected'}, {'award_score':{'id':'collect_forest_ink','points':250}}]),
        'Collect the black goo in my bottle.'),
    (response('need_bottle', 'mushroom_need_bottle', when={'not':{'has_item':'empty_bottle'}}),
        'I have nothing to carry it in.'),
    (response('lick_goo', event='mushroom_poisoning'), 'Lick it.'),
    (response('leave'), 'I will come back.')])
node('mushroom_need_bottle', 'Could I put it in a cup?',
     'A bottle with a stopper would be wiser. Someone in town must have emptied one by now.', [
    (response('leave'), 'I will look in town.')])
node('mushroom_collected', 'That should do for ink.',
     'Keep the stopper in. Hendrik needs ink on his maps, not on your insides.', [
    (response('leave'), 'Back to Hendrik, then.')])
node('inkcap_choices', 'This mushroom is oozing black liquid.',
     'The talking mushroom calls it ink. It looks ready to bottle.', [
    (response('collect_ink', 'mushroom_collected', when=collect_when, once=True, effects=[
        {'remove_item':'empty_bottle'}, {'add_item':'ink_bottle'},
        {'set_flag':'forest_ink_collected'}, {'award_score':{'id':'collect_forest_ink','points':250}}]), 'Collect the goo in my bottle.'),
    (response('need_bottle', 'mushroom_need_bottle', when={'not':{'has_item':'empty_bottle'}}), 'I need a container.'),
    (response('lick_goo', event='mushroom_poisoning'), 'Lick it.'),
    (response('leave'), 'Leave it alone.')])
actor('inkcap', [{'dialogue':'mushroom_collected', 'when':flag('forest_ink_collected')},
                 {'dialogue':'inkcap_choices', 'when':flag('navigator_ink_quest_started')}],
      {'look':'inkcap_look'})
graph['inventory_items']['empty_bottle'] = {'usable':True}
graph['inventory_items']['tartu_route_map'] = {'usable':False}
graph['quests']['navigator_ink']['rewards'] = {'tartu_route_map':1}
graph['pickups'] = {'empty_bottle_pickup':'empty_bottle'}
en['dialogues']['npc_ink_thanks']['text'] = 'Just what I needed. Here is your reward: a map of the trading route from Tallinn to Tartu. Your first journey starts here.'
en['quests']['navigator_ink'].update(description='Find a container, find ink, and bring it to Hendrik.',
    completed='Hendrik takes the ink and gives me the Tallinn-Tartu trading-route map. Demo complete!')
en['items']['empty_bottle'] = {'name':'Empty bottle', 'look':'An empty bottle from beside the sleeping drunk. It could hold ink.',
    'touch':'I could fill this with the black mushroom goo.'}
en['items']['tartu_route_map'] = {'name':'Tallinn-Tartu route', 'look':'Hendrik\'s map of the trading route from Tallinn to Tartu. My first route!',
    'touch':'I carefully unfold the map. The road leads to Tartu.'}
for id, name in [('female_clothes_trader','Clothes trader'),('city_guard','City guard'),('forest_mushroom','Forest mushroom'),('inkcap','Inkcap')]:
    en['actors'][id] = {'name':name}
messages = {
    'city_exit_locked':'I should ask the city guard where to go first.',
    'city_guard_look':'A guard keeps watch beside the city gate.',
    'empty_bottle_look':'An empty bottle. The man beside it is completely passed out.',
    'sleeping_drunk_look':'Fast asleep. His bottle is empty.',
    'sleeping_drunk_talk':'Only snoring. He is not waking up.',
    'metsavana_silent':'Metsavana does not reply. The gnomes keep scraping. A nearby mushroom seems to be watching me.',
    'metsavana_look':'Gnomes are carefully scraping and cleaning the huge forest figure.',
    'mushroom_look':'A mushroom that looks as though it has something to say.',
    'inkcap_look':'A mushroom oozes a thick black liquid.',
    'gnome_look':'A gnome scrapes away, pausing now and then to catch his breath.',
    'mushroom_poisoned':'The goo is poisonous. You turn green and collapse. Click to retry before tasting it; your quest progress is safe.',
    'exit_look':'The road continues. Walk here to travel.',
}
for id, text in messages.items(): message(id, text)
for id, actions in {
    'empty_bottle_pickup':{'look':'empty_bottle_look'},
    'sleeping_drunk':{'look':'sleeping_drunk_look','talk':'sleeping_drunk_talk'},
    'metsavana':{'look':'metsavana_look','talk':'metsavana_silent'},
    'gnome_worker':{'look':'gnome_look'},
    'city_exit':{'look':'exit_look'}, 'to_town':{'look':'exit_look'},
    'to_forest':{'look':'exit_look'}, 'to_river':{'look':'exit_look'},
}.items(): graph['objects'][id] = {'actions':actions}
en['scene'] = {'empty_bottle_pickup':'Bottle', 'sleeping_drunk':'Sleeping drunk',
    'forest_mushroom':'Mushroom', 'inkcap':'Inkcap', 'gnome_worker':'Gnome',
    'city_exit':'City exit', 'to_town':'To town', 'to_forest':'To forest', 'to_river':'To river'}
save('resources/dialogues/revalia_dialogues.json', graph)
save('resources/translations/en.json', en)

def entity(id, pos, size, asset=None, type='quest_prop', actor=None, **kwargs):
    d = dict(type=type, asset_id=asset or f'placeholder:{id}', interaction_id=id,
             feet_position=pos, size=size, perspective_scaling=False, depth_sorting=True)
    if actor: d['dialogue_actor_id'] = actor
    d.update(kwargs)
    return d

town = json.loads((STAGE/'resources/scenarios/town_square.json').read_text())
town['arrivals'] = {'river_crossing':[160,125]}
for e in town['entities']:
    if e['interaction_id'] == 'female_clothes_trader': e['dialogue_actor_id'] = 'female_clothes_trader'
town['entities'].extend([
    entity('sleeping_drunk',[111,165],[52,22]),
    entity('empty_bottle_pickup',[142,168],[25,16]),
    entity('city_guard',[180,135],[50,85],asset='old_sailor',type='npc',actor='city_guard',perspective_scaling=True),
    entity('city_exit',[160,111],[46,16],type='exit',destination='river_crossing'),
])
save('resources/scenarios/town_square.json', town)

def scenario(id, background, entities, arrivals):
    return dict(id=id, background=background, perspective=dict(horizon_y=75, minimum_walkable_y=110,
        minimum_scale=0.35, maximum_scale=0.8), walking_area={'vertices':[[0,130],[320,130],[320,180],[0,180]]},
        player={'feet_position':[45,169], 'size':[50,84]}, entities=entities, arrivals=arrivals)

river = scenario('river_crossing','resources/images/eestlandriver128x91.png',[
    entity('to_town',[30,172],[46,18],type='exit',destination='town_square'),
    entity('to_forest',[288,172],[50,18],type='exit',destination='forest'),
], {'town_square':[65,169], 'forest':[255,169]})
# A narrow bridge-shaped corridor keeps the crossing spatially readable.
river['walking_area']['vertices'] = [[0,150],[135,150],[135,120],[185,120],[185,150],[320,150],[320,178],[185,178],[185,148],[135,148],[135,178],[0,178]]
save('resources/scenarios/river_crossing.json',river)
forest = scenario('forest','resources/images/quest-forest-background.png',[
    entity('metsavana',[177,167],[137,120],asset='resources/images/quest-metsavana.png'),
    entity('gnome_worker',[126,170],[32,30]),
    entity('forest_mushroom',[236,171],[46,24],actor='forest_mushroom'),
    entity('inkcap',[287,174],[30,20],actor='inkcap'),
    entity('to_river',[30,172],[48,18],type='exit',destination='river_crossing'),
], {'river_crossing':[60,170]})
save('resources/scenarios/forest.json',forest)
shutil.copy2(ROOT.parent/'forest background-v2.png', STAGE/'resources/images/quest-forest-background.png')
shutil.copy2(ROOT/'metsavana-pixel-1.png', STAGE/'resources/images/quest-metsavana.png')
print('Prepared quest state, dialogues, VIEWs, and scenario data in', STAGE)
