import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:revalia/game/states/level_game/behaviours/grab_action_behaviour.dart';
import 'package:revalia/game/states/level_game/behaviours/look_action_behaviour.dart';
import 'package:revalia/game/states/level_game/behaviours/move_action_behaviour.dart';
import 'package:revalia/game/states/level_game/view/level_entity.dart';

class WalkingAreaEntity extends LevelEntity {
  WalkingAreaEntity({required List<Vector2> vertices})
      : assert(
            vertices.length >= 3, 'A walking area needs at least 3 vertices.'),
        vertices =
            vertices.map((vertex) => vertex.clone()).toList(growable: false),
        super(
          position: _boundsCenter(vertices),
          size: _boundsSize(vertices),
          interactionId: 'walking_area',
          behaviors: [
            LookActionBehaviour(),
            GrabActionBehaviour(),
            MoveActionBehaviour(),
          ],
        );

  /// World-coordinate corners, connected in this order and closed automatically.
  final List<Vector2> vertices;

  final Paint _guidePaint = Paint()..color = const Color(0x3000FF80);

  @override
  bool containsLocalPoint(Vector2 point) {
    return containsWorldPoint(absolutePositionOf(point));
  }

  bool containsWorldPoint(Vector2 point) {
    var isInside = false;
    for (var i = 0, j = vertices.length - 1; i < vertices.length; j = i++) {
      final current = vertices[i];
      final previous = vertices[j];
      final crossesHorizontalRay =
          (current.y > point.y) != (previous.y > point.y);
      if (!crossesHorizontalRay) {
        continue;
      }

      final edgeIntersectionX = (previous.x - current.x) *
              (point.y - current.y) /
              (previous.y - current.y) +
          current.x;
      if (point.x < edgeIntersectionX) {
        isInside = !isInside;
      }
    }
    return isInside;
  }

  Vector2 constrainWorldPoint(Vector2 requestedPoint) {
    if (containsWorldPoint(requestedPoint)) {
      return requestedPoint.clone();
    }

    var closestPoint = vertices.first.clone();
    var closestDistanceSquared = double.infinity;
    for (var i = 0; i < vertices.length; i++) {
      final edgeStart = vertices[i];
      final edgeEnd = vertices[(i + 1) % vertices.length];
      final candidate = _closestPointOnSegment(
        requestedPoint,
        edgeStart,
        edgeEnd,
      );
      final distanceSquared = candidate.distanceToSquared(requestedPoint);
      if (distanceSquared < closestDistanceSquared) {
        closestDistanceSquared = distanceSquared;
        closestPoint = candidate;
      }
    }
    return closestPoint;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final first = absoluteToLocal(vertices.first);
    final path = Path()..moveTo(first.x, first.y);
    for (final vertex in vertices.skip(1)) {
      final localVertex = absoluteToLocal(vertex);
      path.lineTo(localVertex.x, localVertex.y);
    }
    path.close();
    canvas.drawPath(path, _guidePaint);
  }

  static Vector2 _closestPointOnSegment(
    Vector2 point,
    Vector2 segmentStart,
    Vector2 segmentEnd,
  ) {
    final segment = segmentEnd - segmentStart;
    final lengthSquared = segment.length2;
    if (lengthSquared == 0) {
      return segmentStart.clone();
    }
    final projection =
        ((point - segmentStart).dot(segment) / lengthSquared).clamp(0.0, 1.0);
    return segmentStart + segment * projection;
  }

  static Vector2 _boundsCenter(List<Vector2> vertices) {
    final bounds = _bounds(vertices);
    return Vector2(
      (bounds.$1 + bounds.$2) / 2,
      (bounds.$3 + bounds.$4) / 2,
    );
  }

  static Vector2 _boundsSize(List<Vector2> vertices) {
    final bounds = _bounds(vertices);
    return Vector2(bounds.$2 - bounds.$1, bounds.$4 - bounds.$3);
  }

  static (double, double, double, double) _bounds(List<Vector2> vertices) {
    var minX = vertices.first.x;
    var maxX = vertices.first.x;
    var minY = vertices.first.y;
    var maxY = vertices.first.y;
    for (final vertex in vertices.skip(1)) {
      minX = math.min(minX, vertex.x);
      maxX = math.max(maxX, vertex.x);
      minY = math.min(minY, vertex.y);
      maxY = math.max(maxY, vertex.y);
    }
    return (minX, maxX, minY, maxY);
  }
}
