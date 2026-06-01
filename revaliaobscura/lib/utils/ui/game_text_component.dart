import 'package:revalia/revalia_obs.dart';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GameTextComponent extends PositionedEntity {
  bool switchColor = false;
  static int CRITICAL = 0;
  static int NORMAL = 1;
  static int WARNING = 2;
  static int HIGHLIGHT = 3;
  int status = NORMAL;
  bool hasColorChanged = false;

  late TextPaint textNormal;
  late TextPaint textCritical;
  late TextPaint textWarning;
  late TextPaint textHighlight;

  late TextComponent textComponent; // Holds the actual text
  Color tcolor;
  double fontSize;
  String fontName = "scumm";

  GameTextComponent(String text,
      {required this.fontSize,
      required bool isBlinking,
      required double interval,
      required this.tcolor,
      required Vector2 position,
      Vector2? componentSize,
      double? maxWidth})
      : super(position: position, size: componentSize ?? Vector2(200, 32)) {
    // Adjust size if needed
    final textRenderer = TextPaint(
        style:
            TextStyle(fontSize: fontSize, color: tcolor, fontFamily: fontName));
    textComponent = maxWidth == null
        ? TextComponent(
            text: text,
            textRenderer: textRenderer,
            position: Vector2.zero(), // Centered inside parent
          )
        : TextBoxComponent(
            text: text,
            textRenderer: textRenderer,
            boxConfig: TextBoxConfig(
              maxWidth: maxWidth,
              timePerChar: 0,
            ),
            position: Vector2.zero(),
          );

    textCritical = TextPaint(
      style: TextStyle(
        color: const Color.fromARGB(255, 161, 61, 59),
        fontSize: fontSize,
        fontFamily: fontName,
        backgroundColor: Color.fromARGB(255, 255, 136, 0),
      ),
    );

    textHighlight = TextPaint(
      style: TextStyle(
        color: const Color.fromARGB(255, 238, 255, 0),
        fontSize: fontSize,
        fontFamily: fontName,
        backgroundColor: Color.fromARGB(255, 0, 119, 255),
      ),
    );

    textWarning = TextPaint(
      style: TextStyle(
        color: const Color.fromARGB(255, 227, 210, 67),
        fontSize: fontSize,
        fontFamily: fontName,
      ),
    );

    textNormal = TextPaint(
      style: TextStyle(
        color: tcolor,
        fontSize: fontSize,
        fontFamily: fontName,
      ),
    );

    add(textComponent); // ✅ Adds text to this PositionedEntity
  }

  void updateUI(int status) {
    if (status == CRITICAL) {
      textComponent.textRenderer = textCritical;
    } else if (status == NORMAL) {
      textComponent.textRenderer = textNormal;
    } else if (status == WARNING) {
      textComponent.textRenderer = textWarning;
    } else if (status == HIGHLIGHT) {
      textComponent.textRenderer = textHighlight;
    }
    hasColorChanged = true;
  }

  void updateText(String newText) {
    textComponent.text = newText;
  }

  @override
  void onRemove() {
    // TODO: implement onRemove
    super.onRemove();
  }
}
