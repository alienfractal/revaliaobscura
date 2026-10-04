import 'package:flame/components.dart';

class ScenarioConfig {
  const ScenarioConfig({
    required this.id,
    required this.backgroundId,
    required this.showPerspectiveGuide,
    required this.perspective,
    required this.walkingAreaVertices,
    required this.player,
    required this.entities,
  });

  factory ScenarioConfig.fromJson(Map<String, dynamic> json) {
    final walkingArea = _map(json, 'walking_area');
    final vertices = _list(walkingArea, 'vertices')
        .map((value) => _vector(value, 'walking_area.vertices'))
        .toList(growable: false);
    if (vertices.length < 3) {
      throw const FormatException(
        'Scenario walking_area needs at least three vertices.',
      );
    }

    return ScenarioConfig(
      id: _string(json, 'id'),
      backgroundId: _string(json, 'background'),
      showPerspectiveGuide: json['show_perspective_guide'] as bool? ?? false,
      perspective: ScenarioPerspectiveConfig.fromJson(
        _map(json, 'perspective'),
      ),
      walkingAreaVertices: vertices,
      player: ScenarioPlayerConfig.fromJson(_map(json, 'player')),
      entities: _list(json, 'entities')
          .map(
            (value) => ScenarioEntityConfig.fromJson(
              value as Map<String, dynamic>,
            ),
          )
          .toList(growable: false),
    );
  }

  final String id;
  final String backgroundId;
  final bool showPerspectiveGuide;
  final ScenarioPerspectiveConfig perspective;
  final List<Vector2> walkingAreaVertices;
  final ScenarioPlayerConfig player;
  final List<ScenarioEntityConfig> entities;
}

class ScenarioPerspectiveConfig {
  const ScenarioPerspectiveConfig({
    required this.horizonY,
    required this.minimumWalkableY,
    required this.minimumScale,
    required this.maximumScale,
  });

  factory ScenarioPerspectiveConfig.fromJson(Map<String, dynamic> json) {
    final minimumScale = _number(json, 'minimum_scale');
    final maximumScale = _number(json, 'maximum_scale');
    if (minimumScale <= 0 || maximumScale < minimumScale) {
      throw const FormatException('Invalid scenario perspective scale range.');
    }
    return ScenarioPerspectiveConfig(
      horizonY: _number(json, 'horizon_y'),
      minimumWalkableY: _number(json, 'minimum_walkable_y'),
      minimumScale: minimumScale,
      maximumScale: maximumScale,
    );
  }

  final double horizonY;
  final double minimumWalkableY;
  final double minimumScale;
  final double maximumScale;
}

class ScenarioPlayerConfig {
  const ScenarioPlayerConfig({required this.feetPosition, required this.size});

  factory ScenarioPlayerConfig.fromJson(Map<String, dynamic> json) {
    return ScenarioPlayerConfig(
      feetPosition: _vector(json['feet_position'], 'player.feet_position'),
      size: _vector(json['size'], 'player.size'),
    );
  }

  final Vector2 feetPosition;
  final Vector2 size;
}

class ScenarioEntityConfig {
  const ScenarioEntityConfig({
    required this.type,
    required this.assetId,
    required this.interactionId,
    required this.dialogueActorId,
    required this.feetPosition,
    required this.size,
    required this.isWalkable,
    required this.scalesWithPerspective,
    required this.sortsWithDepth,
  });

  factory ScenarioEntityConfig.fromJson(Map<String, dynamic> json) {
    return ScenarioEntityConfig(
      type: _string(json, 'type'),
      assetId: _string(json, 'asset_id'),
      interactionId: _string(json, 'interaction_id'),
      dialogueActorId: json['dialogue_actor_id'] as String?,
      feetPosition: _vector(json['feet_position'], 'entity.feet_position'),
      size: _vector(json['size'], 'entity.size'),
      isWalkable: json['walkable'] as bool? ?? false,
      scalesWithPerspective: json['perspective_scaling'] as bool? ?? true,
      sortsWithDepth: json['depth_sorting'] as bool? ?? true,
    );
  }

  final String type;
  final String assetId;
  final String interactionId;
  final String? dialogueActorId;
  final Vector2 feetPosition;
  final Vector2 size;
  final bool isWalkable;
  final bool scalesWithPerspective;
  final bool sortsWithDepth;
}

Map<String, dynamic> _map(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! Map<String, dynamic>) {
    throw FormatException('Scenario field "$key" must be an object.');
  }
  return value;
}

List<dynamic> _list(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! List<dynamic>) {
    throw FormatException('Scenario field "$key" must be a list.');
  }
  return value;
}

String _string(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw FormatException('Scenario field "$key" must be a string.');
  }
  return value;
}

double _number(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! num) {
    throw FormatException('Scenario field "$key" must be a number.');
  }
  return value.toDouble();
}

Vector2 _vector(dynamic value, String fieldName) {
  if (value is! List<dynamic> ||
      value.length != 2 ||
      value[0] is! num ||
      value[1] is! num) {
    throw FormatException(
      'Scenario field "$fieldName" must be a two-number list.',
    );
  }
  return Vector2((value[0] as num).toDouble(), (value[1] as num).toDouble());
}
