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
  void onLoad() {
    super.onLoad();
    switch (backgroundId) {
      case 'town_center':
        add(game.entitySpriteCache.townCenterBackground.getSpriteComponent());
      default:
        throw ArgumentError.value(
          backgroundId,
          'backgroundId',
          'Unknown scenario background ID',
        );
    }
    //add(game.entitySpriteCache.townCenterMarketAnimation.getSpriteAnimationComponent());
  }
}
