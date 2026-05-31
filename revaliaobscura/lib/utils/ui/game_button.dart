import 'package:revalia/revalia_obs.dart';

import 'package:revalia/gen/assets.gen.dart';
import 'package:revalia/utils/image/image_utils.dart';
import 'package:flame/components.dart';
import 'package:flame/sprite.dart';

import 'package:flame_behaviors/flame_behaviors.dart';

import '../../game/states/main_menu/behaviours/start_button_taphandler.dart';

class GameButton extends PositionedEntity with HasGameRef<RevaliaObs> {
  late SpriteComponent spriteComponent;

  late String imagePath = "";
  late Behavior behavior;
  late Vector2 imgSize;
  late SpriteSheet spriteSheet ;
  late bool isSimpleSpriteSheet;
  int currentFrameIndex = 0;

  late int rows;

  late int columns;
  GameButton(
      {required super.position,
      required this.imagePath,
      required this.behavior,
      required this.imgSize,
      this.isSimpleSpriteSheet = false,
      this.columns = 1,
      this.rows = 1})
      : super(anchor: Anchor.center, size: imgSize);

  Future<void> init() async {
    if (isSimpleSpriteSheet) {
      SpriteSheet sprs = await ComponentUtils.loadSpriteSheet(imagePath, imgSize, columns, rows, gameRef);
      spriteComponent = SpriteComponent(
        sprite: sprs.getSprite(0, 0),
        size: imgSize,
      );
      
      spriteSheet = sprs;
      setFrame( currentFrameIndex);
      add(spriteComponent);
      add(behavior);
      //setFrame(2);
    } else {
      spriteComponent = await ComponentUtils.createSpriteComponent(path: imagePath, imgSize: imgSize);
      add(spriteComponent);
      add(behavior);
    }
  }

  @override
  Future<void>  onLoad() async  {
    await super.onLoad();
    await init();
  }

void setFrame(int frameIndex) {
    if ( spriteSheet != null) {
      print("game_button setFrame $frameIndex");
      spriteComponent.sprite = spriteSheet.getSpriteById(frameIndex);
    } else {
      print("spriteComponent not initialized yet");
    }
  }
}
