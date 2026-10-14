import 'dart:io';
import 'dart:ui' as ui;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:revalia/game/states/level_game/view/gameboard_view.dart';
import 'package:revalia/game/states/level_game/view/inventory_popup.dart';
import 'package:revalia/utils/components/actionable_entitty_component.dart';
import 'package:revalia/utils/dialogsystem/dialog_manager.dart';

import 'adventure_state_test.dart' show loadAdventureGraph;

class _InventoryBoard extends GameboardView {
  bool closed = false;
  String? usedItem;
  final List<String> requestedText = [];
  final Map<String, String> text = {
    'inventory.title': 'Inventory',
    'inventory.click_hint': 'Choose an action in the HUD, then click an item.',
    'inventory.no_tasks': 'No tasks yet.',
    'inventory.cannot_talk': 'It does not have much to say.',
    'inventory.cannot_walk': 'I cannot walk on this.',
    'inventory.actions.look': 'Look at',
    'inventory.actions.touch': 'Touch / Use',
    'inventory.actions.talk': 'Talk to',
    'inventory.actions.move': 'Walk to',
    'inventory.actions.use': 'Use',
    'items.task_scroll.name': 'Tasks',
    'items.task_scroll.look': 'A yellow scroll containing my current tasks.',
    'items.ink_bottle.name': 'Ink',
    'items.ink_bottle.look': 'A bottle of dark ink.',
  };

  @override
  String adventureText(String key) {
    requestedText.add(key);
    return text[key] ?? key;
  }

  @override
  void closeInventory() => closed = true;

  @override
  void selectInventoryItem(String itemId) {
    usedItem = itemId;
    closeInventory();
  }
}

class _InventoryGame extends FlameGame {
  final InventoryPopup popup;
  _InventoryGame(this.popup);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await camera.viewport.add(popup);
  }
}

Future<Offset> _mount(WidgetTester tester, InventoryPopup popup) async {
  final game = _InventoryGame(popup);
  await tester.pumpWidget(MaterialApp(
      home: Align(
    alignment: Alignment.topLeft,
    child: RepaintBoundary(
        key: const Key('inventory-preview'),
        child:
            SizedBox(width: 320, height: 200, child: GameWidget(game: game))),
  )));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 16));
  return tester.getTopLeft(find.byType(GameWidget<_InventoryGame>));
}

Future<void> _unmount(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpWidget(const SizedBox.shrink());
  expect(tester.takeException(), isNull);
}

void main() {
  setUpAll(() async {
    final font = FontLoader('scumm')
      ..addFont(rootBundle.load('resources/fonts/SCUMM-Font.ttf'));
    await font.load();
  });

  setUp(() {
    DialogueManager.fsm
        .configure(graph: loadAdventureGraph(), translations: {});
    DialogueManager.fsm.storyState.adventure.addItem('ink_bottle');
  });

  testWidgets('grid item clicks use the active HUD action without changing it',
      (tester) async {
    final board = _InventoryBoard();
    final popup = InventoryPopup(board);
    final origin = await _mount(tester, popup);
    for (final action in [
      ActionableType.look,
      ActionableType.talk,
      ActionableType.move
    ]) {
      board.actionType = action;
      board.requestedText.clear();
      await tester.tapAt(origin + const Offset(100, 69));
      await tester.pump();
      final key = switch (action) {
        ActionableType.look => 'items.ink_bottle.look',
        ActionableType.talk => 'inventory.cannot_talk',
        _ => 'inventory.cannot_walk',
      };
      expect(board.requestedText, contains(key));
      expect(board.actionType, action);
      expect(board.usedItem, isNull);
      expect(board.closed, isFalse);
    }
    board.actionType = ActionableType.touch;
    await tester.tapAt(origin + const Offset(100, 69));
    expect(board.usedItem, 'ink_bottle');
    expect(board.closed, isTrue);
    await _unmount(tester);
  });

  testWidgets(
      'scroll look describes it; touch opens tasks; empty slots do nothing',
      (tester) async {
    final board = _InventoryBoard()..actionType = ActionableType.look;
    final popup = InventoryPopup(board);
    final origin = await _mount(tester, popup);
    await tester.tapAt(origin + const Offset(40, 69));
    expect(board.requestedText, contains('items.task_scroll.look'));
    expect(board.requestedText, isNot(contains('inventory.no_tasks')));
    board.actionType = ActionableType.touch;
    await tester.tapAt(origin + const Offset(40, 69));
    await tester.pump();
    expect(board.requestedText, contains('inventory.no_tasks'));
    expect(board.closed, isFalse);
    expect(board.usedItem, isNull);
    await tester.tapAt(origin + const Offset(280, 111));
    expect(board.usedItem, isNull);
    expect(board.closed, isFalse);
    // Opt-in visual QA artifact; normal test runs never write an image.
    final previewPath = Platform.environment['INVENTORY_PREVIEW'];
    if (previewPath != null) {
      await tester.runAsync(() async {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const Key('inventory-preview')));
        final image = await boundary.toImage(pixelRatio: 3);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(previewPath).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }
    await tester.tapAt(origin + const Offset(297, 37));
    expect(board.closed, isTrue);
    await _unmount(tester);
  });

  testWidgets('item-specific talk reactions override the default response',
      (tester) async {
    final board = _InventoryBoard()..actionType = ActionableType.talk;
    board.text['items.ink_bottle.talk'] = 'The ink remains silent.';
    final origin = await _mount(tester, InventoryPopup(board));
    board.requestedText.clear();
    await tester.tapAt(origin + const Offset(100, 69));
    expect(board.requestedText, contains('items.ink_bottle.talk'));
    expect(board.requestedText, isNot(contains('inventory.cannot_talk')));
    await _unmount(tester);
  });

  testWidgets('grid supports the second row and pages after ten slots',
      (tester) async {
    final graph = loadAdventureGraph();
    final items = graph['inventory_items'] as Map<String, dynamic>;
    for (var i = 0; i < 11; i++) {
      items['item_$i'] = {'usable': true};
    }
    DialogueManager.fsm.configure(graph: graph, translations: {});
    for (var i = 0; i < 11; i++) {
      DialogueManager.fsm.storyState.adventure.addItem('item_$i');
    }
    final board = _InventoryBoard()..actionType = ActionableType.look;
    final origin = await _mount(tester, InventoryPopup(board));
    await tester.tapAt(origin + const Offset(40, 111));
    expect(board.requestedText, contains('items.item_4.look'));
    await tester.tapAt(origin + const Offset(292, 189));
    await tester.pump();
    await tester.tapAt(origin + const Offset(40, 69));
    expect(board.requestedText, contains('items.item_9.look'));
    await _unmount(tester);
  });

  test('popup leaves the top HUD clickable while blocking the scene', () {
    final popup = InventoryPopup(_InventoryBoard());
    expect(popup.containsLocalPoint(Vector2(140, 12)), isFalse);
    expect(popup.containsLocalPoint(Vector2(302, 10)), isFalse);
    expect(popup.containsLocalPoint(Vector2(160, 100)), isTrue);
    expect(popup.containsLocalPoint(Vector2(0, 195)), isTrue);
  });
}
