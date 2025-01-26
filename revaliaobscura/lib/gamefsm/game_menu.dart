import 'package:coolorburn/revalia_obs.dart';
import 'package:coolorburn/gamefsm/fsm.dart';
import 'package:coolorburn/gamefsm/istate.dart';

class GameMenu implements IState{
  late RevaliaObs mainGame;

  GameMenu();
  
  @override
  void enter(Fsm gameFsm) {
   
    mainGame.switchToWorld(mainGame.menuView);
    gameFsm.actions+="M";

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