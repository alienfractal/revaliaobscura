import 'package:coolorburn/revalia_obs.dart';
import 'package:coolorburn/gamefsm/fsm.dart';
import 'package:coolorburn/gamefsm/istate.dart';

class GameLoading implements IState{
  late RevaliaObs mainGame;
  GameLoading();

  @override
  void enter(Fsm gameFsm) {
   
   // gameFsm.currentStateType = StateType.GameLoading;
    mainGame.switchToWorld(mainGame.loadingView);
    gameFsm.actions+="L";
  }

  @override
  void exit(Fsm gameFsm) {
 
    gameFsm.actions+="X";
        mainGame.clearWorld(gameFsm.currentStateType);
     

  }

  @override
  void update(double dt) {
    
  }



}