import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' show Colors, TextStyle;
import 'package:revalia/revalia_obs.dart';

class LanguageButton extends PositionComponent
    with TapCallbacks, HasGameRef<RevaliaObs> {
  static final Vector2 buttonSize = Vector2.all(17);

  final List<String> locales;
  final void Function(String locale) onSelected;

  late final TextComponent _labelComponent;
  late final TextPaint _textPaint;

  LanguageButton({
    required this.locales,
    required this.onSelected,
    required super.position,
  })  : assert(locales.length > 1),
        super(anchor: Anchor.center, size: buttonSize, priority: 10);

  String get currentLocale => gameRef.currentLocale;

  String get currentLabel => currentLocale.toUpperCase();

  @override
  void onLoad() {
    super.onLoad();
    _textPaint = TextPaint(
      style: const TextStyle(
        fontSize: 6,
        color: Colors.white,
        fontFamily: 'scumm',
        fontFamilyFallback: ['press2p'],
      ),
    );
    _labelComponent = TextComponent(
      text: currentLabel,
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: _textPaint,
    );
    add(_labelComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _labelComponent.text = currentLabel;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      size.toRect(),
      Paint()..color = const Color(0xff191919),
    );
    canvas.drawRect(
      size.toRect().deflate(0.5),
      Paint()
        ..color = const Color(0xff8a8fc4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    super.render(canvas);
  }

  @override
  void onTapDown(TapDownEvent event) {
    final currentIndex = locales.indexOf(currentLocale);
    final nextIndex =
        currentIndex < 0 ? 0 : (currentIndex + 1) % locales.length;
    onSelected(locales[nextIndex]);
    super.onTapDown(event);
  }
}
