import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:revalia/dialoguefsm/adventure_state.dart';
import 'package:revalia/game/states/level_game/view/gameboard_view.dart';
import 'package:revalia/gen/assets.gen.dart';
import 'package:revalia/utils/dialogsystem/dialog_manager.dart';
import 'package:revalia/utils/components/actionable_entitty_component.dart';

/// Shares its size and center alignment with the other HUD action buttons.
class InventoryButton extends PositionComponent with TapCallbacks {
  final GameboardView board;
  Sprite? _sprite;

  InventoryButton(this.board,
      {required Vector2 position, required Vector2 buttonSize})
      : super(
            position: position,
            size: buttonSize.clone(),
            anchor: Anchor.center,
            priority: 9000);

  @override
  Future<void> onLoad() async {
    _sprite = await board.game
        .loadSprite(Assets.resources.images.actionIconInventory24x24.path);
  }

  @override
  void render(Canvas canvas) {
    _sprite?.render(canvas, size: size);
    final selected = board.selectedInventoryItem;
    if (selected != null) {
      final text = TextPainter(
          text: TextSpan(
              text: '${board.adventureText('inventory.using')} '
                  '${board.adventureText('items.$selected.name')}',
              style: const TextStyle(
                  fontFamily: 'scumm',
                  fontSize: 8,
                  color: Color(0xffffdb69),
                  backgroundColor: Color(0xff231f25))),
          textDirection: TextDirection.ltr)
        ..layout(maxWidth: 230);
      final topLeft = position - size / 2;
      text.paint(canvas, Offset(8 - topLeft.x, 182 - topLeft.y));
      text.dispose();
    }
  }

  @override
  void onTapDown(TapDownEvent event) => board.toggleInventory();
}

/// Five-column item grid using the same action state as the scene HUD.
/// The top HUD remains interactive; everything below it blocks scene taps.
class InventoryPopup extends PositionComponent with TapCallbacks {
  static const int columns = 5;
  static const int rows = 2;
  static const Rect gridBounds = Rect.fromLTWH(10, 48, 300, 108);
  static const Rect _modalBounds = Rect.fromLTWH(0, 26, 320, 174);
  static const Rect _messageBounds = Rect.fromLTWH(18, 161, 284, 19.2);

  final GameboardView board;
  final List<({Rect rect, void Function() action})> _targets = [];
  final Map<String, Sprite> _icons = {};
  String? _selected;
  int _itemPage = 0;
  int _detailPage = 0;
  String? _reaction;
  bool _readingJournal = false;

  InventoryPopup(this.board) : super(size: Vector2(320, 200), priority: 10001);

  AdventureState get state => DialogueManager.fsm.storyState.adventure;

  @override
  Future<void> onLoad() async {
    for (final item in state.items.values) {
      if (item.icon != null) {
        _icons[item.id] = await board.game.loadSprite(item.icon!);
      }
    }
  }

  String tr(String key) => board.adventureText(key);

  @override
  bool containsLocalPoint(Vector2 point) =>
      _modalBounds.contains(point.toOffset());

  @override
  void onTapDown(TapDownEvent event) {
    final point = event.localPosition.toOffset();
    for (final target in _targets.reversed) {
      if (target.rect.contains(point)) {
        target.action();
        return;
      }
    }
  }

  void _activateItem(String id) {
    if (!state.hasItem(id)) return;
    _selected = id;
    _detailPage = 0;
    _readingJournal = false;
    switch (board.actionType) {
      case ActionableType.look:
        _reaction = tr('items.$id.look');
      case ActionableType.talk:
        _reaction = _itemReaction(id, 'talk', 'inventory.cannot_talk');
      case ActionableType.move:
        _reaction = _itemReaction(id, 'walk', 'inventory.cannot_walk');
      case ActionableType.touch:
      case ActionableType.use:
        if (id == 'task_scroll') {
          _readingJournal = true;
          _reaction = null;
        } else if (state.items[id]?.usable ?? false) {
          board.selectInventoryItem(id);
        } else {
          _reaction = tr('items.$id.touch');
        }
    }
  }

  String _itemReaction(String id, String action, String fallback) {
    final key = 'items.$id.$action';
    final value = tr(key);
    return value == key ? tr(fallback) : value;
  }

  @override
  void render(Canvas canvas) {
    _targets.clear();
    canvas.drawRect(_modalBounds, Paint()..color = const Color(0xaa000000));
    _box(
        canvas, const Rect.fromLTWH(10, 28, 300, 172), const Color(0xff27241b));
    _text(canvas, tr('inventory.title'), 18, 33, 100, fontSize: 9);
    _text(
        canvas, tr('inventory.actions.${board.actionType.name}'), 124, 34, 155,
        fontSize: 8, maxLines: 1);
    _button(canvas, const Rect.fromLTWH(288, 30, 18, 15), 'X',
        board.closeInventory);

    final ids = state.inventory.keys.toList();
    const capacity = columns * rows;
    final pages = math.max(1, (ids.length / capacity).ceil());
    _itemPage = _itemPage.clamp(0, pages - 1);
    for (int slot = 0; slot < capacity; slot++) {
      final rect = Rect.fromLTWH(
          gridBounds.left + (slot % columns) * gridBounds.width / columns,
          gridBounds.top + (slot ~/ columns) * gridBounds.height / rows,
          gridBounds.width / columns,
          gridBounds.height / rows);
      final index = _itemPage * capacity + slot;
      final id = index < ids.length ? ids[index] : null;
      final selected = id != null && id == _selected;
      _slot(canvas, rect, selected: selected);
      if (id == null) continue;
      final iconRect =
          Rect.fromCenter(center: rect.center, width: 30, height: 30);
      if (_icons.containsKey(id)) {
        _icons[id]!.render(canvas,
            position: Vector2(iconRect.left, iconRect.top),
            size: Vector2(iconRect.width, iconRect.height));
      } else if (id == 'task_scroll') {
        canvas.save();
        canvas.translate(iconRect.left + 2, iconRect.top);
        canvas.scale(1.8);
        _drawScroll(canvas, Offset.zero);
        canvas.restore();
      } else {
        _box(canvas, iconRect.deflate(3), const Color(0xff57678b));
        _text(canvas, tr('items.$id.name'), rect.left + 3, rect.bottom - 12,
            rect.width - 6,
            fontSize: 7, maxLines: 1);
      }
      final count = state.quantity(id);
      if (count > 1) {
        _text(canvas, 'x$count', rect.left + 3, rect.top + 2, rect.width - 6,
            fontSize: 7, maxLines: 1);
      }
      _targets.add((rect: rect, action: () => _activateItem(id)));
    }

    final detail =
        _readingJournal ? _journal() : _reaction ?? tr('inventory.click_hint');
    final painter = _painter(detail, _messageBounds.width, 8);
    final detailPages =
        math.max(1, (painter.height / _messageBounds.height).ceil());
    _detailPage = _detailPage.clamp(0, detailPages - 1);
    canvas.save();
    canvas.clipRect(_messageBounds);
    painter.paint(
        canvas,
        Offset(_messageBounds.left,
            _messageBounds.top - _detailPage * _messageBounds.height));
    canvas.restore();
    painter.dispose();
    if (detailPages > 1) {
      _button(canvas, const Rect.fromLTWH(18, 182, 18, 15), '<', () {
        _detailPage = (_detailPage - 1 + detailPages) % detailPages;
      });
      _text(canvas, '${_detailPage + 1}/$detailPages', 40, 185, 40,
          fontSize: 7);
      _button(canvas, const Rect.fromLTWH(82, 182, 18, 15), '>', () {
        _detailPage = (_detailPage + 1) % detailPages;
      });
    }
    if (pages > 1) {
      _button(canvas, const Rect.fromLTWH(206, 182, 18, 15), '<', () {
        _itemPage = (_itemPage - 1 + pages) % pages;
      });
      _text(canvas, '${_itemPage + 1}/$pages', 228, 185, 40, fontSize: 7);
      _button(canvas, const Rect.fromLTWH(284, 182, 18, 15), '>', () {
        _itemPage = (_itemPage + 1) % pages;
      });
    }
  }

  String _journal() {
    final quests = state.journal.toList();
    if (quests.isEmpty) return tr('inventory.no_tasks');
    return quests.map((quest) {
      final status = state.status(quest.id);
      final lines = <String>[
        tr('quests.${quest.id}.title'),
        tr('inventory.${status.name}'),
        tr('quests.${quest.id}.description'),
      ];
      if (status != QuestStatus.completed) {
        for (final entry in quest.requiredItems.entries) {
          lines.add('${tr('items.${entry.key}.name')}: '
              '${math.min(state.quantity(entry.key), entry.value)}/${entry.value}');
        }
      }
      return lines.join('\n');
    }).join('\n\n');
  }

  void _slot(Canvas canvas, Rect rect, {required bool selected}) {
    canvas.drawRect(rect, Paint()..color = const Color(0xff080904));
    canvas.drawRect(
        rect.deflate(1),
        Paint()
          ..color =
              (selected ? const Color(0xff796c43) : const Color(0xff504832)));
    canvas.drawLine(
        Offset(rect.left + 2, rect.top + 2),
        Offset(rect.right - 2, rect.top + 2),
        Paint()..color = const Color(0xff756b4e));
    canvas.drawLine(
        Offset(rect.left + 2, rect.top + 2),
        Offset(rect.left + 2, rect.bottom - 2),
        Paint()..color = const Color(0xff756b4e));
  }

  void _drawScroll(Canvas canvas, Offset position) {
    _box(canvas, Rect.fromLTWH(position.dx + 2, position.dy, 10, 16),
        const Color(0xffedca61));
    final paint = Paint()..color = const Color(0xffb88a36);
    for (final y in [0.0, 15.0]) {
      canvas.drawRect(
          Rect.fromLTWH(position.dx, position.dy + y, 14, 2), paint);
    }
    for (final y in [5.0, 8.0, 11.0]) {
      canvas.drawRect(
          Rect.fromLTWH(position.dx + 4, position.dy + y, 6, 1), paint);
    }
  }

  void _box(Canvas canvas, Rect rect, Color color) {
    canvas.drawRect(rect, Paint()..color = color);
    canvas.drawRect(
        rect.deflate(0.5),
        Paint()
          ..color = const Color(0xffa48c61)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);
  }

  void _button(Canvas canvas, Rect rect, String text, void Function() action) {
    _box(canvas, rect, const Color(0xff49402b));
    _text(canvas, text, rect.left + 4, rect.top + 2, rect.width - 8,
        fontSize: 8, maxLines: 1);
    _targets.add((rect: rect, action: action));
  }

  TextPainter _painter(String text, double width, double fontSize,
      {int? maxLines}) {
    return TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              fontFamily: 'scumm',
              fontSize: fontSize,
              height: 1.2,
              color: const Color(0xfff1deb7))),
      textDirection: TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: maxLines == null ? null : '...',
    )..layout(maxWidth: width);
  }

  void _text(Canvas canvas, String text, double x, double y, double width,
      {double fontSize = 8, int? maxLines}) {
    final painter = _painter(text, width, fontSize, maxLines: maxLines);
    painter.paint(canvas, Offset(x, y));
    painter.dispose();
  }
}
