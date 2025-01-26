
import 'package:coolorburn/revalia_obs.dart';
import 'package:coolorburn/utils/image_utils.dart';
import 'package:coolorburn/utils/text_component.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class TextUtils {

  static const Color yellowText =  Color(0xffe3d245);
  static const Color coolblueText =  Color(0xff8a8fc4);

  
  static String capitalize(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }

  static String formatTime(double time) {
    final minutes = (time / 60).floor().toString().padLeft(2, '0');
    final seconds = (time % 60).floor().toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  static String formatScore(int score) {
    return score.toString().padLeft(6, '0');
  }

    static BlinkingTextComponent addTextToview(RevaliaObs gameRef,String text, Vector2 position, double fontSize, bool isBlinking, Color color, double interval, bool shouldCenter)  {
    BlinkingTextComponent textComponent = BlinkingTextComponent(
      text,
      position,
      fontSize: fontSize,
      isBlinking: isBlinking,
      tcolor: color,
      interval: interval
    );
    
    if (shouldCenter) {
      
      textComponent.position = ComponentUtils.centerComponent(
        gameRef.camDimension, textComponent,
        offsetX: 2, offsetY: 4);
    }
    
    return textComponent;
  }


}