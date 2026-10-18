import 'package:revalia/revalia_obs.dart';

import 'package:revalia/utils/image/image_utils.dart';
import 'package:revalia/utils/image/sprite_animator_cache_service.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

import 'package:flame_behaviors/flame_behaviors.dart';

class GameButton extends PositionedEntity with HasGameRef<RevaliaObs> {
  late SpriteComponent spriteComponent;

  String? imagePath;
  SpriteComponent? cachedSpriteComponent;
  CachedSpriteSheet? cachedSpriteSheet;
  late Behavior behavior;
  late Vector2 imgSize;
  SpriteSheet? spriteSheet;
  late bool isSimpleSpriteSheet;
  int currentFrameIndex = 0;

  late int rows;

  late int columns;
  GameButton(
      {required super.position,
      this.imagePath,
      this.cachedSpriteComponent,
      this.cachedSpriteSheet,
      required this.behavior,
      required this.imgSize,
      this.isSimpleSpriteSheet = false,
      this.columns = 1,
      this.rows = 1})
      : super(anchor: Anchor.center, size: imgSize);

  Future<void> init() async {
    if (isSimpleSpriteSheet) {
      final sprs = cachedSpriteSheet?.spriteSheet ??
          await ComponentUtils.loadSpriteSheet(
              imagePath!, imgSize, columns, rows, gameRef);
      spriteComponent = SpriteComponent(
        sprite: sprs.getSprite(0, 0),
        size: imgSize,
      );

      spriteSheet = sprs;
      setFrame(currentFrameIndex);
      add(spriteComponent);
      add(behavior);
      //setFrame(2);
    } else {
      spriteComponent = cachedSpriteComponent ??
          await ComponentUtils.createSpriteComponent(
              path: imagePath!, imgSize: imgSize);
      add(spriteComponent);
      add(behavior);
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await init();
  }

  void setFrame(int frameIndex) {
    final sheet = spriteSheet;
    if (sheet != null) {
      print("game_button setFrame $frameIndex");
      final frameCount = columns * rows;
      currentFrameIndex = frameCount > 0 ? frameIndex % frameCount : 0;
      spriteComponent.sprite = sheet.getSpriteById(currentFrameIndex);
    } else {
      print("spriteComponent not initialized yet");
    }
  }

  void advanceFrame() {
    setFrame(currentFrameIndex + 1);
  }
}
