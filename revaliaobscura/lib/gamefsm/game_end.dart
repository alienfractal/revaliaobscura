import 'package:coolorburn/revalia_obs.dart';
import 'package:coolorburn/gamefsm/fsm.dart';
import 'package:coolorburn/gamefsm/istate.dart';

class GameEnd implements IState {
  late RevaliaObs mainGame;
  GameEnd();
  @override
  void enter(Fsm gameFsm) {
  
    gameFsm.actions += "E";
    mainGame.switchToWorld(mainGame.endView);
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
