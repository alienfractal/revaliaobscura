class UtilsMisc {
  //Apply a CA rule know for creating mazes
  List<List<int>> genCAMaze(
      List<List<int>> board, int validCell, int invalidCell) {
    int boardSize = board.length;
    List<List<int>> newBoard =
        List.generate(boardSize, (i) => List.filled(boardSize, validCell));
    //print('itr gameboardModel newboard ${newBoard.toString()}');
    //print('itr gameboardModel board ${board.toString()}');
    for (int x = 0; x < boardSize; x++) {
      for (int y = 0; y < boardSize; y++) {
        int neighbors = countNeighbors(board, x, y);

        if (board[x][y] == validCell) {
          // Survival rule: remain a wall if neighbors are 1-5
          newBoard[x][y] =
              (neighbors >= 1 && neighbors <= 5) ? validCell : invalidCell;
        } else {
          // Birth rule: become a wall if exactly 3 neighbors
          newBoard[x][y] = (neighbors == 3) ? validCell : invalidCell;
        }
      }
    }

    return newBoard;
  }

  int countNeighbors(List<List<int>> board, int x, int y) {
    int count = 0;
    List<List<int>> directions = [
      [-1, -1],
      [-1, 0],
      [-1, 1],
      [0, -1],
      /* [0, 0], */
      [0, 1],
      [1, -1],
      [1, 0],
      [1, 1]
    ];

    for (List<int> direction in directions) {
      int dx = x + direction[0];
      int dy = y + direction[1];

      if (dx >= 0 && dx < board.length && dy >= 0 && dy < board[dx].length) {
        //any cell with value > 0 is considered alive in most cases, state values can range from 1 to 9 and have different purposes.
        count += board[dx][dy] > 0 ? 1 : 0;
      }
    }

    return count;
  }

  List<List<int>> initEmptyArray(int size) {
    List<List<int>> board =
        List.generate(size, (i) => List.generate(size, (j) => 0));
    return board;
  }

  void printFancyArray(List<List<int>> array) {
    for (var row in array) {
      // Format each row as a string with elements separated by commas
      String formattedRow = row.map((e) => e.toString().padLeft(3)).join(", ");
      print("[ $formattedRow ]");
    }
  }
}
