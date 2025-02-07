import 'package:coolorburn/revalia_obs.dart';
import 'package:coolorburn/utils/image/sprite_animator_cache_service.dart';
import 'package:flame/components.dart';
import 'package:flame/image_composition.dart';
import 'package:flame/sprite.dart';

class ComponentUtils {
// Method to load the sprite and create the component
  static Future<SpriteComponent> createSpriteComponent(
      {required String path, required Vector2 imgSize}) async {
    Sprite sprite = await SpriteAnimatorCache.loadSprite(path);
    //print(sprite.srcSize.toString());

    return SpriteComponent(sprite: sprite, size: imgSize);
  }

  static Future<List<SpriteComponent>> createTiledSpriteComponent(
      {required String path,
      required Vector2 tileSize,
      required Vector2 compSize}) async {
    List<SpriteComponent> spriteComponents = List.empty(growable: true);
    int tileCountX = (compSize.x / tileSize.x).ceil();
    int tileCountY = (compSize.y / tileSize.y).ceil();

    for (int i = 0; i < tileCountX; i++) {
      for (int j = 0; j < tileCountY; j++) {
        Sprite sprite = await SpriteAnimatorCache.loadSprite(path);
        SpriteComponent spriteComponent =
            SpriteComponent(sprite: sprite, size: tileSize);
        spriteComponent.position = Vector2(i * tileSize.x, j * tileSize.y);
        spriteComponents.add(spriteComponent);
      }
    }
    return spriteComponents;
  }

  

  static Vector2 centerComponent(
      Vector2 camDimension, PositionComponent posComponent,
      {double offsetX = 2, double offsetY = 2}) {
    final double x = (offsetX > 0
            ? (camDimension.x - posComponent.size.x) / offsetX
            : posComponent.x) +
        posComponent.position.x;
    final double y = (offsetY > 0
            ? (camDimension.y - posComponent.size.y) / offsetY
            : posComponent.y) +
        posComponent.position.y;
    return Vector2(x, y);
  }

  
  static Future<SpriteSheet> loadSpriteSheet(String imagePath, Vector2 imgSize, int col, int row, RevaliaObs gameRef) async {

    return SpriteSheet.fromColumnsAndRows(
      image: await gameRef.images.load(imagePath), // Load the spritesheet image
      columns: col, // Number of columns in the spritesheet
      rows:row,    // Number of rows in the spritesheet
    );


  }
}
