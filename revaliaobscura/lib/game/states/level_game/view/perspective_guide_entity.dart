import 'dart:ui';

import 'package:flame/components.dart';
import 'package:revalia/game/states/level_game/perspective/perspective_config.dart';

class PerspectiveGuideEntity extends PositionComponent {
  PerspectiveGuideEntity()
      : super(
          position: Vector2.zero(),
          size: Vector2(
            PerspectiveConfig.worldWidth,
            PerspectiveConfig.worldHeight,
          ),
          priority: 1000,
        );

  final Paint _horizonPaint = Paint()..color = const Color(0xCC00FFFF);
  final Paint _vanishingPointPaint = Paint()..color = const Color(0xFFFF3B30);

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final vanishingPoint = PerspectiveConfig.vanishingPoint;

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        PerspectiveConfig.horizonY,
        PerspectiveConfig.worldWidth,
        1,
      ),
      _horizonPaint,
    );
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(vanishingPoint.x, vanishingPoint.y),
        width: 3,
        height: 3,
      ),
      _vanishingPointPaint,
    );
  }
}
