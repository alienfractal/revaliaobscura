import 'package:revalia/revalia_obs.dart';
import 'package:revalia/gamefsm/fsm.dart';
import 'package:revalia/gamefsm/istate.dart';

class GameMenu implements IState {
  late RevaliaObs mainGame;

  GameMenu();

  @override
  void enter(Fsm gameFsm) {
    mainGame.switchToWorld(mainGame.menuView);
    gameFsm.actions += "M";
  }

  @override
  void exit(Fsm gameFsm) {
    gameFsm.actions += "X";
    mainGame.clearWorld(gameFsm.currentStateType);
  }

  @override
  void update(double dt) {}
}
