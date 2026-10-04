import 'package:flutter_test/flutter_test.dart';
import 'package:revalia/game/states/level_game/scenario/scenario_config.dart';

void main() {
  test('parses scenario placement and entity options', () {
    final scenario = ScenarioConfig.fromJson({
      'id': 'town_square',
      'background': 'town_center',
      'show_perspective_guide': true,
      'perspective': {
        'horizon_y': 90,
        'minimum_walkable_y': 102,
        'minimum_scale': 0.2,
        'maximum_scale': 1.1,
      },
      'walking_area': {
        'vertices': [
          [160, 102],
          [320, 200],
          [0, 200],
        ],
      },
      'player': {
        'feet_position': [160, 200],
        'size': [50, 84],
      },
      'entities': [
        {
          'type': 'animated_prop',
          'asset_id': 'glowing_gem',
          'interaction_id': 'glowing_gem',
          'feet_position': [220, 170],
          'size': [32, 32],
          'walkable': true,
        },
      ],
    });

    expect(scenario.id, 'town_square');
    expect(scenario.walkingAreaVertices, hasLength(3));
    expect(scenario.player.feetPosition.x, 160);
    expect(scenario.entities.single.assetId, 'glowing_gem');
    expect(scenario.entities.single.isWalkable, isTrue);
    expect(scenario.entities.single.scalesWithPerspective, isTrue);
  });

  test('rejects a walking area with fewer than three vertices', () {
    expect(
      () => ScenarioConfig.fromJson({
        'id': 'invalid',
        'background': 'town_center',
        'perspective': {
          'horizon_y': 90,
          'minimum_walkable_y': 102,
          'minimum_scale': 0.2,
          'maximum_scale': 1.1,
        },
        'walking_area': {
          'vertices': [
            [0, 0],
            [1, 1],
          ],
        },
        'player': {
          'feet_position': [0, 0],
          'size': [50, 84],
        },
        'entities': <dynamic>[],
      }),
      throwsFormatException,
    );
  });
}
