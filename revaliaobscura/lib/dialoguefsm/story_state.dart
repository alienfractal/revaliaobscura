class StoryState {
  final Map<String, bool> _flags = {};
  final Set<String> _consumedResponses = {};

  bool flag(String id) => _flags[id] ?? false;

  bool isResponseConsumed(String id) => _consumedResponses.contains(id);

  bool matches(Map<String, dynamic>? condition) {
    if (condition == null || condition.isEmpty) {
      return true;
    }

    final flagId = condition['flag'] as String?;
    if (flagId != null) {
      return flag(flagId) == (condition['equals'] as bool? ?? true);
    }

    final all = condition['all'] as List<dynamic>?;
    if (all != null) {
      return all.every(
        (item) => matches(item as Map<String, dynamic>),
      );
    }

    final any = condition['any'] as List<dynamic>?;
    if (any != null) {
      return any.any(
        (item) => matches(item as Map<String, dynamic>),
      );
    }

    final not = condition['not'] as Map<String, dynamic>?;
    if (not != null) {
      return !matches(not);
    }

    throw FormatException('Unsupported dialogue condition: $condition');
  }

  void applyEffects(List<Map<String, dynamic>> effects) {
    for (final effect in effects) {
      final flagId = effect['set_flag'] as String?;
      if (flagId != null) {
        _flags[flagId] = effect['value'] as bool? ?? true;
        continue;
      }

      // Score awards are forwarded to the game by DialogueManager.
      if (effect['award_score'] is Map<String, dynamic>) {
        continue;
      }

      throw FormatException('Unsupported dialogue effect: $effect');
    }
  }

  void consumeResponse(String id) {
    _consumedResponses.add(id);
  }

  void clear() {
    _flags.clear();
    _consumedResponses.clear();
  }
}
