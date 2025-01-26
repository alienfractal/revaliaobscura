import 'package:coolorburn/revalia_obs.dart';
import 'package:coolorburn/gamefsm/fsm.dart';
import 'package:coolorburn/gamefsm/istate.dart';

class GameStart implements IState {

  late RevaliaObs mainGame;
  GameStart();
  @override
  void enter(Fsm gameFsm) {
 
    
    mainGame.switchToWorld(mainGame.gboard);
    gameFsm.actions += "S";
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
