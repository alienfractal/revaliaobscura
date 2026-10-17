import 'package:flame/components.dart';

class PerspectiveConfig {
  static const double worldWidth = 320;
  static const double worldHeight = 200;
  static const double characterScaleStepPixels = 8;

  // Start with the horizon and single vanishing point at screen centre.
  static double horizonY = 90;
  static double nearestWalkableHorizonY = 102;
  static const double characterFeetToEyeHeight = 45;
  static double minimumCharacterScale = 0.2;
  static double maximumCharacterScale = 1.1;
  static Vector2 get vanishingPoint => Vector2(worldWidth / 2, horizonY);

  static void configure({
    required double horizonY,
    required double nearestWalkableHorizonY,
    required double minimumCharacterScale,
    required double maximumCharacterScale,
  }) {
    PerspectiveConfig.horizonY = horizonY;
    PerspectiveConfig.nearestWalkableHorizonY = nearestWalkableHorizonY;
    PerspectiveConfig.minimumCharacterScale = minimumCharacterScale;
    PerspectiveConfig.maximumCharacterScale = maximumCharacterScale;
  }

  /// Larger feet Y values are closer to the camera and render in front.
  static int depthPriorityForFeetY(double feetY) => feetY.round();

  static double characterScaleForFeetY(double feetY) {
    final depth = ((feetY - nearestWalkableHorizonY) /
            (worldHeight - nearestWalkableHorizonY))
        .clamp(0.0, 1.0);

    return minimumCharacterScale +
        (maximumCharacterScale - minimumCharacterScale) * depth;
  }

  /// Returns the perspective scale in retro, eight-pixel height steps.
  ///
  /// The steps are measured from the sprite's authored height. This keeps the
  /// sprite at its exact original size when the perspective scale is 1 while
  /// still making every size change an eight-pixel jump.
  static double steppedCharacterScaleForFeetY(
    double feetY, {
    required double unscaledHeight,
  }) {
    if (unscaledHeight <= 0) {
      throw ArgumentError.value(
        unscaledHeight,
        'unscaledHeight',
        'The unscaled character height must be greater than zero.',
      );
    }

    final smoothScale = characterScaleForFeetY(feetY);
    final smoothHeightDelta = (smoothScale - 1) * unscaledHeight;
    final steppedHeightDelta =
        (smoothHeightDelta / characterScaleStepPixels).round() *
            characterScaleStepPixels;
    final steppedHeight = unscaledHeight + steppedHeightDelta;

    // Very small configured scale values must never collapse the sprite.
    return steppedHeight.clamp(characterScaleStepPixels, double.infinity) /
        unscaledHeight;
  }
}
