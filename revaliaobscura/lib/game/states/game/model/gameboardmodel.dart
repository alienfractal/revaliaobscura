import 'dart:collection';

import 'package:revalia/game/states/game/model/actor_model.dart';

//for rock (0), hot (1), cold (2), start point (3), and exit point (4).

enum ActionOutcome {
  validMove,
  invalidMove,
  timeOver,
  levelCompleted,
}

class GameBoardModel {
  int rows = 0; // Number of rows in the grid
  int columns = 0; // Number of columns in the grid
  int counter = 0;
  List<List<int>> board = List.empty();

  List<ActorModel> enemies = List<ActorModel>.empty();
  int energyCount = 10; // Starting number of flames
  int currentLevel = 0;
  double levelPlayTime = 30; //Standard Time limit for each level
  int bombCount = 1;
  int coinCount = 0;

  int totalScore = 0;
  int baseScore = 0; // Starting score
  Queue<ActorModel> currentQueue = Queue<ActorModel>();

  int relicCount = 0;

  ActionOutcome flipResultOutcome = ActionOutcome.validMove;

  void setLevelVariables(int level) {
    currentLevel += 1;
    flipResultOutcome = ActionOutcome.validMove;
  }

  void calculateScore() {
    totalScore = 0;
  }

  void initGameBoard(int level) {
    //print('current level : $level');
    setLevelVariables(level);
    coinCount = 0;
  }
}

void main() {}
