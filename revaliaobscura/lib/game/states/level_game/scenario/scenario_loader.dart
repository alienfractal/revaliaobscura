import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:revalia/game/states/level_game/scenario/scenario_config.dart';

class ScenarioLoader {
  static Future<ScenarioConfig> load(String assetPath) async {
    final source = await rootBundle.loadString(assetPath);
    return ScenarioConfig.fromJson(
      jsonDecode(source) as Map<String, dynamic>,
    );
  }
}
