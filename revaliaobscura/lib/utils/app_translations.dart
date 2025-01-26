import 'dart:convert';

import 'package:coolorburn/gen/assets.gen.dart';
import 'package:flutter/services.dart';

class AppTranslations {
  static  Map<String, Map<String, String>> allTranslations = {};

  Map<String, String> flattenJson(Map<String, dynamic> json,
      [String prefix = '']) {
    final Map<String, String> result = {};

    json.forEach((key, value) {
      final fullKey = prefix.isEmpty ? key : '$prefix.$key';

      if (value is String) {
        result[fullKey] = value;
      } else if (value is Map<String, dynamic>) {
        // Recursively flatten nested maps
        result.addAll(flattenJson(value, fullKey));
      } else if (value is List<dynamic>) {
        // Flatten lists with indexed keys
        for (var i = 0; i < value.length; i++) {
          final item = value[i];
          if (item is String) {
            result['$fullKey[$i]'] = item;
          }
        }
      } else {
        throw ArgumentError('Unsupported type for key: $fullKey');
      }
    });

    return result;
  }

  Future<void> loadTranslations() async {
    // Load English translations
    String enJson =
        await rootBundle.loadString(Assets.resources.translations.en);
    allTranslations['en'] =
        flattenJson(jsonDecode(enJson) as Map<String, dynamic>);

    // Load Spanish translations (or other locales)
    String esJson =
        await rootBundle.loadString(Assets.resources.translations.es);
    allTranslations['es'] =
        flattenJson(jsonDecode(esJson) as Map<String, dynamic>);
  }

  static String getTranslation(String locale, String key) {
    return allTranslations[locale]?[key] ?? 'Translation not found';
  }
}
