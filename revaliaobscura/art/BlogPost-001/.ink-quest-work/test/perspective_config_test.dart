import 'package:flutter_test/flutter_test.dart';
import 'package:revalia/game/states/level_game/perspective/perspective_config.dart';

void main() {
  const characterHeight = 84.0;

  setUp(() {
    PerspectiveConfig.configure(
      horizonY: 90,
      nearestWalkableHorizonY: 102,
      minimumCharacterScale: 0.2,
      maximumCharacterScale: 1.1,
    );
  });

  test('character perspective height changes in eight-pixel steps', () {
    for (var feetY = 102.0; feetY <= 200; feetY += 1) {
      final scale = PerspectiveConfig.steppedCharacterScaleForFeetY(
        feetY,
        unscaledHeight: characterHeight,
      );
      final heightDelta = characterHeight * scale - characterHeight;
      final stepCount = heightDelta / 8;

      expect(stepCount, closeTo(stepCount.roundToDouble(), 0.000001));
    }
  });

  test('a scale of one preserves the authored character size', () {
    const scaleRange = 1.1 - 0.2;
    const depthAtNativeSize = (1.0 - 0.2) / scaleRange;
    const feetYAtNativeSize = 102 + (200 - 102) * depthAtNativeSize;

    final scale = PerspectiveConfig.steppedCharacterScaleForFeetY(
      feetYAtNativeSize,
      unscaledHeight: characterHeight,
    );

    expect(scale, closeTo(1, 0.000001));
    expect(characterHeight * scale, closeTo(characterHeight, 0.000001));
  });

  test('the configured near and far sizes snap to retro steps', () {
    final farScale = PerspectiveConfig.steppedCharacterScaleForFeetY(
      102,
      unscaledHeight: characterHeight,
    );
    final nearScale = PerspectiveConfig.steppedCharacterScaleForFeetY(
      200,
      unscaledHeight: characterHeight,
    );

    expect(characterHeight * farScale, closeTo(20, 0.000001));
    expect(characterHeight * nearScale, closeTo(92, 0.000001));
  });

  test('32-pixel scene props snap to eight-pixel sizes', () {
    const propHeight = 32.0;
    final middleDistanceScale = PerspectiveConfig.steppedCharacterScaleForFeetY(
      170,
      unscaledHeight: propHeight,
    );
    final farDistanceScale = PerspectiveConfig.steppedCharacterScaleForFeetY(
      140,
      unscaledHeight: propHeight,
    );

    expect(propHeight * middleDistanceScale, closeTo(24, 0.000001));
    expect(propHeight * farDistanceScale, closeTo(16, 0.000001));
  });
}
