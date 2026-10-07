import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' show Colors, TextStyle;
import 'package:revalia/revalia_obs.dart';

class LanguageButton extends PositionComponent
    with TapCallbacks, HasGameRef<RevaliaObs> {
  static final Vector2 buttonSize = Vector2.all(20);

  final String locale;
  final String label;
  final void Function(String locale) onSelected;

  late final TextComponent _labelComponent;
  late final TextPaint _activeTextPaint;
  late final TextPaint _inactiveTextPaint;

  LanguageButton({
    required this.locale,
    required this.label,
    required this.onSelected,
    required super.position,
  }) : super(size: buttonSize, priority: 10);

  bool get isSelected => gameRef.currentLocale == locale;

  @override
  void onLoad() {
    super.onLoad();
    _activeTextPaint = TextPaint(
      style: const TextStyle(
        fontSize: 6,
        color: Colors.black,
        fontFamily: 'scumm',
        fontFamilyFallback: ['press2p'],
      ),
    );
    _inactiveTextPaint = TextPaint(
      style: const TextStyle(
        fontSize: 6,
        color: Colors.white,
        fontFamily: 'scumm',
        fontFamilyFallback: ['press2p'],
      ),
    );
    _labelComponent = TextComponent(
      text: label,
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: isSelected ? _activeTextPaint : _inactiveTextPaint,
    );
    add(_labelComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _labelComponent.textRenderer =
        isSelected ? _activeTextPaint : _inactiveTextPaint;
  }

  @override
  void render(Canvas canvas) {
    final selected = isSelected;
    canvas.drawRect(
      size.toRect(),
      Paint()
        ..color = selected
            ? const Color(0xffe3d245)
            : const Color(0xff191919),
    );
    canvas.drawRect(
      size.toRect().deflate(0.5),
      Paint()
        ..color = selected
            ? const Color(0xffffffff)
            : const Color(0xff8a8fc4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    super.render(canvas);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onSelected(locale);
    super.onTapDown(event);
  }
}
