/// Location IDs stay independent of artwork and of the global game FSM.
class QuestLocations {
  static const town = 'town_square';
  static const gates = 'city_gates';
  static const river = 'river_crossing';
  static const forest = 'forest';
  static const paths = {
    town: 'resources/scenarios/town_square.json',
    gates: 'resources/scenarios/city_gates.json',
    river: 'resources/scenarios/river_crossing.json',
    forest: 'resources/scenarios/forest.json',
  };

  static bool canTravel(String from, String to, {required bool gateUnlocked}) {
    if (!gateUnlocked) return false;
    return (from == town && to == gates) ||
        (from == gates && (to == town || to == river)) ||
        (from == river && (to == gates || to == forest)) ||
        (from == forest && to == river);
  }
}
