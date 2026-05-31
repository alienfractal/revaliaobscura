import 'package:revalia/utils/ui/game_generic_button.dart';

class GenericButtonManager {
  final List<GenericButton> buttons = [];

  void addButton(GenericButton button) {
    buttons.add(button);
  }

  void onButtonTapped(GenericButton tappedButton) {
    // Change the color of all buttons to gray
    for (var button in buttons) {
      button.isActive(false);
    }

    // Optionally, you can change the tapped button to a different color
    tappedButton.isActive(true); // Or any other color
  }
}