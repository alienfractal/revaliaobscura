class ActorModel {
  static const int WALL = 0;
  static const int ICE = 1;
  static const int FIRE = 2;
  static const int PLAYER = 3;
  static const int END = 4;
  static const int BOMB = 5;
  static const int YETI = 6;
  static const int GOLD = 7;
  static const int DIRT = 8;
  static const int FLOOR = 9;
  static const int RUBBLE = 10;
  static const int EMPTY_ENEMY = 11;
  static const int RELIC = 12;
  static const int GRAVE = 13;
  static const int BROKEN_GRAVE = 14;
  static const int BACK_ANIM = 15;
  static const int OLD_SAILOR = 16;


  /// Constructor with required fields
  ActorModel({
    required this.x,
    required this.y,
    required this.distance,
    required this.status,
    this.prev,
  }) {
    oldValue = status;
  }

  int x, y, distance, status, oldValue = 0;
  int health = 0;
  final ActorModel? prev; // Nullable, as the starting Actor does not have a 'prev'

  @override
  String toString() {
    // Example format: Actor(x: 1, y: 2, distance: 3)
    return 'Actor(x: $x, y: $y, Actortype: $status, distance: $distance, parent: ${prev != null}, health: $health)';
  }
}
