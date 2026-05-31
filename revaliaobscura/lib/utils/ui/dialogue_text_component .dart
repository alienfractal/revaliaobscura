
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

class DialogueTextComponent extends TextBoxComponent {
// ✅ Disable anti-aliasing for sharp pixel edges
  
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
          pixelRatio: 4.0
        ) {
    textRenderer = TextPaint(
      style: TextStyle(
        fontSize: fontSize,
        color: textColor,
        fontFamily: fontName,
       
       // ✅ Prevents underlining artifacts
      ),
    );
  }

  static TextBoxConfig newTextBoxConfig() {
    return const TextBoxConfig(
      maxWidth: 220, // ✅ Ensures word wrapping
      timePerChar: 0.05, // ✅ Optional text reveal effect
      margins: EdgeInsets.all(5),
      
      
    );
  }


}
