 

import 'package:revalia/revalia_obs.dart';
 

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
 



 void main()  {
  Flame.images.prefix = "";
  FlameAudio.audioCache.prefix = "";
  Flame.assets.prefix = "";
  WidgetsFlutterBinding.ensureInitialized();
  

  



  // Create the Flame game instance
  final RevaliaObs cob = RevaliaObs(); // Pass the delegate to your game

  // Load translations
 
   GameWidget gameWidget = GameWidget(game: cob);
   
 

  
 
  //runApp(gameWidget);

    runApp(gameWidget);
  // Run the app with GameWidget.controlled
 
}



