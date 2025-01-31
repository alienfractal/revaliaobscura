import 'package:flame/components.dart';
enum ActionableType {
  look,
  touch,
  talk,
  move,
  use
}
abstract class ActionableEntityComponent {
  void onLook();
  void onTouch();
  void onTalk();
  void onMove(Vector2 newLocation);
  void onUse(); // New action: "Use" an item or object
}