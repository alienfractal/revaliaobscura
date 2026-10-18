import 'package:revalia/game/states/level_game/view/gameboard_view.dart';
import 'package:revalia/game/states/level_game/model/gameboardmodel.dart';
import 'package:revalia/game/states/level_game/scenario/quest_locations.dart';

class CityGatesView extends GameboardView {
  CityGatesView({required GameBoardModel model, String? arrivedFrom})
      : super(
            model: model,
            locationId: QuestLocations.gates,
            arrivedFrom: arrivedFrom);
}
