import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:revalia/revalia_obs.dart';

class MarketBackgroundEntity extends PositionedEntity
    with HasGameRef<RevaliaObs> {
  MarketBackgroundEntity({
    required super.position,
    required super.size,
  }) : super(anchor: Anchor.center, behaviors: []);

  @override
  void onLoad() {
    super.onLoad();
    add(
      SpriteAnimationComponent(
        animation: gameRef.entitySpriteCache.gameTownAnimationBackground,
        size: Vector2(320, 200),
      ),
    );
  }
}
