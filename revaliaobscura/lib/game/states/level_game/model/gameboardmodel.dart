enum ActionOutcome {
  validMove,
  invalidMove,
  timeOver,
  playerKilled,
  levelCompleted,
}

class GameBoardModel {
  int rows = 0; // Number of rows in the grid
  int columns = 0; // Number of columns in the grid
  int counter = 0;
  List<List<int>> board = List.empty();

  int energyCount = 10;
  int currentLevel = 0;
  double levelPlayTime = 30;
  int coinCount = 0;

  int totalScore = 0;
  final Set<String> _awardedScoreMilestones = {};

  ActionOutcome flipResultOutcome = ActionOutcome.validMove;

  void setLevelVariables(int level) {
    currentLevel += 1;
    flipResultOutcome = ActionOutcome.validMove;
  }

  void calculateScore() {
    // Milestone points are already included in totalScore.
  }

  bool awardScoreMilestone(String milestoneId, int points) {
    if (points <= 0 || !_awardedScoreMilestones.add(milestoneId)) {
      return false;
    }
    totalScore += points;
    return true;
  }

  void resetGameProgress() {
    totalScore = 0;
    _awardedScoreMilestones.clear();
  }

  void initGameBoard(int level) {
    //print('current level : $level');
    setLevelVariables(level);
    coinCount = 0;
  }
}
