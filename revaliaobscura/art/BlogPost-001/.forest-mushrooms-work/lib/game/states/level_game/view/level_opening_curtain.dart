import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

class LevelOpeningCurtain extends PositionComponent with TapCallbacks {
  LevelOpeningCurtain({
    required Vector2 screenSize,
    required this.onReady,
    this.onComplete,
    this.durationSeconds = 1.2,
  })  : _initialSize = screenSize.clone(),
        super(
          position: Vector2.zero(),
          size: screenSize.clone(),
          priority: 10000,
        );

  final Vector2 _initialSize;
  final void Function() onReady;
  final void Function()? onComplete;
  final double durationSeconds;
  double _elapsedSeconds = 0;
  double _revealProgress = 0;
  final Paint _blackPaint = Paint()..color = const Color(0xFF000000);

  @override
  void onMount() {
    super.onMount();
    onReady();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsedSeconds += dt;
    _revealProgress = (_elapsedSeconds / durationSeconds).clamp(0.0, 1.0);

    if (_revealProgress >= 1) {
      onComplete?.call();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final revealedWidth = _initialSize.x * _revealProgress;
    final revealedHeight = _initialSize.y * _revealProgress;
    final left = (_initialSize.x - revealedWidth) / 2;
    final top = (_initialSize.y - revealedHeight) / 2;
    final right = left + revealedWidth;
    final bottom = top + revealedHeight;

    // Four black panels surround a window that grows from the center outward.
    canvas.drawRect(Rect.fromLTWH(0, 0, _initialSize.x, top), _blackPaint);
    canvas.drawRect(
      Rect.fromLTWH(0, bottom, _initialSize.x, _initialSize.y - bottom),
      _blackPaint,
    );
    canvas.drawRect(Rect.fromLTWH(0, top, left, revealedHeight), _blackPaint);
    canvas.drawRect(
      Rect.fromLTWH(right, top, _initialSize.x - right, revealedHeight),
      _blackPaint,
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Absorb input until the opening effect has completed.
  }
}
