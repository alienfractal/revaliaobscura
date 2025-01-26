import 'package:coolorburn/revalia_obs.dart';
import 'package:coolorburn/gamefsm/fsm.dart';
import 'package:coolorburn/gamefsm/istate.dart';

class GameScore implements IState {
  late RevaliaObs mainGame;
  GameScore();

  @override
  void enter(Fsm gameFsm) {
 
    // gameFsm.currentStateType = StateType.GameLoading;
    mainGame.switchToWorld(mainGame.scoreView);
    gameFsm.actions += "L";
  }

  @override
  void exit(Fsm gameFsm) {
 
    gameFsm.actions += "X";
    mainGame.clearWorld(gameFsm.currentStateType);
  }

  @override
  void update(double dt) {
 
  }
}
