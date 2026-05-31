import 'package:revalia/gamefsm/fsm.dart';

class GameFsm extends Fsm  {
 

  GameFsm({required super.currentState, required super.mainGame}) {
    
     Fsm.gmenu.mainGame = super.mainGame;
     Fsm.gstart.mainGame = super.mainGame;
     Fsm.gload.mainGame = super.mainGame;
     Fsm.gend.mainGame = super.mainGame;
     Fsm.gscore.mainGame = super.mainGame;
  }
 
  
 void transition(StateType newState) {

    // Exit the current state
    currentState.exit(this);

    // Set the new state
    switch (newState) {
      case StateType.GameMenu:
        currentState = Fsm.gmenu;
        break;
      case StateType.GameLoading:
        currentState = Fsm.gload;
        break;
      case StateType.GameStart:
        currentState = Fsm.gstart;
        break;
      case StateType.GameEnd:
        currentState = Fsm.gend;
        break;
      case StateType.GameScore:
        currentState = Fsm.gscore;
        break;  
    }
    currentStateType = newState;

    // Enter the new state
    currentState.enter(this);
  }

  @override
  void gameEnd() {
    transition(StateType.GameEnd);
  }

  @override
  void gameLoading() {
    transition(StateType.GameLoading);
  }

  @override
  void gameMenu() {
    transition(StateType.GameMenu);
  }

  @override
  void gameStart() {
    transition(StateType.GameStart);
  }
  
  @override
  void gameScore() {
   
    transition(StateType.GameScore);
  }
}