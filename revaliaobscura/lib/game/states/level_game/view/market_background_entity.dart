import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:revalia/revalia_obs.dart';

class MarketBackgroundEntity extends PositionedEntity
    with HasGameReference<RevaliaObs> {
  MarketBackgroundEntity({
    required super.position,
    required super.size,
    required this.backgroundId,
  }) : super(anchor: Anchor.center, behaviors: [], priority: -100);

  final String backgroundId;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    switch (backgroundId) {
      case 'town_center':
        add(game.entitySpriteCache.townCenterBackground.getSpriteComponent());
      default:
        final sprite = await game.loadSprite(backgroundId);
        // Preserve authored pixel proportions; pad rather than stretch artwork.
        final factor = (size.x / sprite.srcSize.x < size.y / sprite.srcSize.y
                ? size.x / sprite.srcSize.x
                : size.y / sprite.srcSize.y)
            .floor();
        final displaySize =
            sprite.srcSize * (factor < 1 ? 1.0 : factor.toDouble());
        add(RectangleComponent(
            size: size.clone(),
            paint: Paint()..color = const Color(0xff171721)));
        add(SpriteComponent(
            sprite: sprite,
            size: displaySize,
            position:
                Vector2((size.x - displaySize.x) / 2, size.y - displaySize.y),
            paint: Paint()..filterQuality = FilterQuality.none));
        return;
    }
    add(
      game.entitySpriteCache.townCenterMarketAnimation
          .getSpriteAnimationComponent(),
    );
  }
}
