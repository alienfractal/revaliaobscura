import 'package:flame/components.dart';

enum ActionableType { look, touch, talk, move, use }

abstract class ActionTarget {
  bool shouldApproachFor(ActionableType actionType);
  Vector2 get interactionPoint;
  void performAction(ActionableType actionType);
}
