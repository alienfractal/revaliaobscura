import 'package:revalia/dialoguefsm/adventure_state.dart';

class StoryState {
  final AdventureState adventure = AdventureState();
  final Map<String, bool> _flags = {};
  final Set<String> _consumedResponses = {};

  bool flag(String id) => _flags[id] ?? false;

  /// The purple mushroom supplies one filled bottle, even without a container.
  bool collectForestInk() {
    if (flag('forest_ink_collected')) return false;
    if (adventure.hasItem('empty_bottle')) {
      adventure.removeItem('empty_bottle');
    }
    adventure.addItem('ink_bottle');
    _flags['forest_ink_collected'] = true;
    return true;
  }

  bool isResponseConsumed(String id) => _consumedResponses.contains(id);

  bool matches(Map<String, dynamic>? condition) {
    if (condition == null || condition.isEmpty) {
      return true;
    }

    final flagId = condition['flag'] as String?;
    if (flagId != null) {
      return flag(flagId) == (condition['equals'] as bool? ?? true);
    }

    final itemId = condition['has_item'] as String?;
    if (itemId != null) {
      return adventure.hasItem(itemId, condition['quantity'] as int? ?? 1);
    }
    final questId = condition['quest'] as String?;
    if (questId != null) {
      return adventure.status(questId).name == condition['status'];
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
      final startQuest = effect['start_quest'] as String?;
      if (startQuest != null) {
        adventure.startQuest(startQuest);
        continue;
      }
      final completeQuest = effect['complete_quest'] as String?;
      if (completeQuest != null) {
        if (!adventure.completeQuest(completeQuest)) {
          throw StateError('Quest is not ready: $completeQuest');
        }
        continue;
      }
      final removed = effect['remove_item'] as String?;
      if (removed != null) {
        if (!adventure.removeItem(removed, effect['quantity'] as int? ?? 1)) {
          throw StateError('Cannot consume item: $removed');
        }
        continue;
      }
      final item = effect['add_item'] as String?;
      if (item != null) {
        adventure.addItem(item, effect['quantity'] as int? ?? 1);
        continue;
      }
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
    adventure.reset();
  }
}
