import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ColorStatusTextComponent extends TextComponent {
  bool switchColor = false;
  static int CRITICAL = 0;
  static int NORMAL = 1;
  static int WARNING = 2;
  int status = NORMAL;
  bool hasColorChanged = false;
  late TextPaint textNormal;
  late TextPaint textCritical;
  late TextPaint textWarning;

  Color tcolor;

  double fontSize = 4;

  ColorStatusTextComponent(String text, Vector2 pos,
      {required this.fontSize,
      required bool isBlinking,
      required double interval,
      required this.tcolor,
      required Vector2 position})
      : super(
          text: text,
          textRenderer: TextPaint(
              style: TextStyle(
                  fontSize: fontSize, color: tcolor, fontFamily: "scumm")),
          position: pos,
        ) {
    textCritical = TextPaint(
      style: TextStyle(
        color: const Color.fromARGB(255, 161, 61, 59),
        fontSize: fontSize,
        fontFamily: "scumm",
        backgroundColor: Color.fromARGB(255, 255, 136, 0)
      ),
    );

        textWarning = TextPaint(
      style: TextStyle(
        color: const Color.fromARGB(255, 227, 210, 67),
        fontSize: fontSize,
        fontFamily: "scumm",
      ),
    );

    textNormal = TextPaint(
      style: TextStyle(
        color: tcolor,
        fontSize: fontSize,
        fontFamily: "scumm",
      ),
    );
  }

  void updateUI(int status) {
    if (status == CRITICAL) {
      // Change to critical color
      textRenderer = textCritical;
      hasColorChanged = true;
    } else if (status == NORMAL) {
      // Ensure the color is normal if not critical
      textRenderer = textNormal;
       hasColorChanged = true;
    }
    else if (status == WARNING) {
      // Ensure the color is normal if not critical
      textRenderer = textWarning;
       hasColorChanged = true;
    }
  }

  void updateText(String newText) {
    super.text = newText;
  }
}
