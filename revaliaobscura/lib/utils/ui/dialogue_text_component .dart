import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

class DialogueTextComponent extends TextBoxComponent {
  static const double maxTextWidth = 220;
  static const EdgeInsets textMargins = EdgeInsets.all(5);

  DialogueTextComponent({
    required String text,
    required Vector2 position,
    Color textColor = Colors.white,
    double fontSize = 8,
    String fontName = "scumm",
  }) : super(
          text: text,
          boxConfig: newTextBoxConfig(),
          position: position,
          pixelRatio: 4.0,
        ) {
    textRenderer = TextPaint(
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
        fontFamily: fontName,
      ),
    );
  }

  static TextBoxConfig newTextBoxConfig() {
    return const TextBoxConfig(
      maxWidth: maxTextWidth,
      timePerChar: 0.05,
      margins: textMargins,
    );
  }

  static double requiredHeight(
    String text, {
    double fontSize = 8,
    String fontName = "scumm",
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, fontFamily: fontName),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxTextWidth - textMargins.horizontal);
    return painter.height + textMargins.vertical;
  }
}
