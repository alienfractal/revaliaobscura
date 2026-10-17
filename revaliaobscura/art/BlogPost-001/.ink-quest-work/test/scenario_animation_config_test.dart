import 'package:flutter_test/flutter_test.dart';
import 'package:revalia/game/states/level_game/scenario/scenario_animation_config.dart';

void main() {
  Map<String, dynamic> spec() =>
      {'frames': 7, 'width': 32, 'height': 82, 'step_time': 0.2};
  test('plain strips retain their sequential playback', () {
    expect(ScenarioAnimationConfig.fromJson(spec()).sequence,
        [1, 2, 3, 4, 5, 6, 7]);
  });
  test('custom sequence keeps repeats and artist frame order', () {
    final sequence = [
      1,
      1,
      1,
      2,
      3,
      5,
      6,
      7,
      5,
      6,
      7,
      5,
      6,
      7,
      1,
      2,
      3,
      4,
      5,
      2,
      2,
      2,
      2,
      1,
      2,
      3,
      4,
      5,
      6,
      7
    ];
    final config =
        ScenarioAnimationConfig.fromJson({...spec(), 'sequence': sequence});
    expect(config.sequence, sequence);
    expect(config.sequence.length * config.stepTime, 6);
  });
  test('invalid frame numbers and empty sequences fail clearly', () {
    for (final sequence in [
      [],
      [0],
      [8],
      [1.5],
      ['1']
    ]) {
      expect(
          () => ScenarioAnimationConfig.fromJson(
              {...spec(), 'sequence': sequence}),
          throwsFormatException);
    }
    for (final patch in [
      {'frames': 0},
      {'width': 0},
      {'height': -1},
      {'step_time': 0}
    ]) {
      expect(() => ScenarioAnimationConfig.fromJson({...spec(), ...patch}),
          throwsFormatException);
    }
  });
}
