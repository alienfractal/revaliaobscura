class PlayerModel {
  static const int IDLE = 0;
  static const int WALKING = 1;
  static const int ATTACK = 2;
  static const int BLOCK = 3;
  static const int NOPE = 4;
  static const int HURTS = 5;
  static const int DIE = 6;
  static const int TALK = 7;
  static const int LAUGH = 8;
  int x, y;
  bool isAlive = true;

  int currentPathIndex = 0;
  int pathStepIndex = 0;
  int status = IDLE;
  bool movingForward = true;
  double attack = 0;
  double defense = 0;

  int health = 0;

  PlayerModel({required this.x, required this.y, required this.status});
}
