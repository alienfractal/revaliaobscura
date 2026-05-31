import 'dart:async';
import 'dart:ui';

import 'package:revalia/revalia_obs.dart';
import 'package:flame/components.dart';


class EnergyBar extends PositionComponent with HasGameRef<RevaliaObs> {
  double maxEnergy;
  double currentEnergy;
  late RectangleComponent energyBar;
  late RectangleComponent energyBarBackground;

  EnergyBar({
    required this.maxEnergy,
    required this.currentEnergy,
    required Vector2 position,
    required Vector2 size, required Vector2 energyBarSize,
  }) : super(position: position, size: size) {
    // Create the background of the energy bar
    energyBarBackground = RectangleComponent(
      position: Vector2.zero(),
      size: size,
      paint: Paint()..color =  Color(0xffa13d3b), // Red background for the energy bar
    );

    // Create the fill part of the energy bar
    energyBar = RectangleComponent(
      position: Vector2.zero(),
      size: Vector2(size.x * (currentEnergy / maxEnergy), size.y),
      paint: Paint()..color = const Color.fromARGB(255, 255, 255, 255), // Green fill for the energy bar
    );

    add(energyBarBackground);
    add(energyBar);
  }

  // Method to update the energy bar's fill based on current energy
  void updateEnergy(double newEnergy) {
    currentEnergy = newEnergy.clamp(0, maxEnergy); // Ensure it stays within bounds
    energyBar.size.x = size.x * (currentEnergy / maxEnergy);
    var r = ((100*currentEnergy.toInt())%255);
    double normalEnergyVal = (currentEnergy / maxEnergy);
      var r2 = (1.0-normalEnergyVal)*255.0;
    //print("game_energy_bar.dart: updateEnergy: normalEnergyVal: $normalEnergyVal currentEnergy: $currentEnergy maxEnergy: $maxEnergy  r2: $r2");
  
    energyBarBackground.setColor(Color.fromARGB(255, r2.toInt(), 61, 59));

  }

  @override
  FutureOr<void> onLoad() {
    // TODO: implement onLoad
   
  }
}

