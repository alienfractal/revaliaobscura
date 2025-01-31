

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

class CRTOverlay extends Component with HasGameRef {
  ui.FragmentShader? shader;
  ui.Image? gameTexture;
  Vector2 camDimension;

  CRTOverlay(this.camDimension);

  @override
  Future<void> onLoad() async {
    final program = await loadShader('resources/shaders/test.frag');
    shader = program.fragmentShader();

    // Set the resolution in the shader
    shader!.setFloat(0, camDimension.x); // uResolution.x
    shader!.setFloat(1, camDimension.y); // uResolution.y

    // Capture the initial game world
    await captureGameWorld();
  }

  Future<void> captureGameWorld() async {
    // Create a picture recorder to capture the rendered game world
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, camDimension.x, camDimension.y));

    // Render the game components onto the off-screen canvas
    gameRef.render(canvas);

    // Finalize the picture and generate the image texture
    final picture = recorder.endRecording();
    gameTexture = await picture.toImage(camDimension.x.toInt(), camDimension.y.toInt());
  }

  @override
  void render(Canvas canvas) {
    if (shader != null && gameTexture != null) {
      //print("CRTOverlay: render shader $shader gameTexture $gameTexture canvas $canvas");
      // Bind the captured texture to the shader
        // Set the resolution in the shader
      shader!.setFloat(0, camDimension.x); // uResolution.x
      shader!.setFloat(1, camDimension.y); // uResolution.y
      shader!.setImageSampler(0, gameTexture!);

      final paint = Paint()..shader = shader;
      
      // Apply the shader effect on the game world texture
      canvas.drawRect(
        Rect.fromLTWH(0, 0, camDimension.x, camDimension.y),
        paint,
      );
    }
  }

  Future<ui.FragmentProgram> loadShader(String assetKey) async {
    return await ui.FragmentProgram.fromAsset(assetKey);
  }
}

