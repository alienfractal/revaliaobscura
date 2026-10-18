enum QuestStatus { available, active, ready, completed }

class InventoryItemDefinition {
  final String id;
  final bool permanent;
  final bool usable;
  final String? icon;

  const InventoryItemDefinition(this.id,
      {this.permanent = false, this.usable = true, this.icon});
}

/// A delivery quest stays active until its items are handed to its recipient.
class QuestDefinition {
  final String id;
  final String recipient;
  final Map<String, int> requiredItems;
  final Map<String, int> rewards;

  const QuestDefinition(this.id, this.recipient, this.requiredItems,
      [this.rewards = const {}]);
}

/// Shared playthrough state. Definitions come from the dialogue graph; no UI
/// or Flutter dependencies are needed to advance inventory and quests.
class AdventureState {
  final Map<String, InventoryItemDefinition> _items = {};
  final Map<String, QuestDefinition> _quests = {};
  final Map<String, int> _inventory = {};
  final Set<String> _started = {};
  final Set<String> _completed = {};
  final Map<String, String> _pickups = {};
  final Set<String> _collected = {};

  Map<String, InventoryItemDefinition> get items => Map.unmodifiable(_items);
  Map<String, int> get inventory => Map.unmodifiable(_inventory);
  Iterable<QuestDefinition> get journal =>
      _quests.values.where((quest) => _started.contains(quest.id));

  void configure(Map<String, dynamic> graph) {
    _items.clear();
    final items = graph['inventory_items'] as Map<String, dynamic>? ?? {};
    for (final entry in items.entries) {
      final data = entry.value as Map<String, dynamic>;
      _items[entry.key] = InventoryItemDefinition(entry.key,
          permanent: data['permanent'] as bool? ?? false,
          usable: data['usable'] as bool? ?? true,
          icon: data['icon'] as String?);
    }
    _quests.clear();
    final quests = graph['quests'] as Map<String, dynamic>? ?? {};
    for (final entry in quests.entries) {
      final data = entry.value as Map<String, dynamic>;
      final required = (data['required_items'] as Map<String, dynamic>)
          .map((id, quantity) => MapEntry(id, quantity as int));
      if (required.isEmpty ||
          required.entries.any((e) =>
              !_items.containsKey(e.key) ||
              _items[e.key]!.permanent ||
              e.value <= 0)) {
        throw FormatException('Invalid required items for quest ${entry.key}');
      }
      final rewards = (data['rewards'] as Map<String, dynamic>? ?? {})
          .map((id, quantity) => MapEntry(id, quantity as int));
      for (final reward in rewards.entries) {
        if (!_items.containsKey(reward.key) || reward.value <= 0) {
          throw FormatException('Invalid reward for quest ${entry.key}');
        }
      }
      _quests[entry.key] = QuestDefinition(
          entry.key,
          data['recipient'] as String,
          Map.unmodifiable(required),
          Map.unmodifiable(rewards));
    }
    _pickups
      ..clear()
      ..addAll((graph['pickups'] as Map<String, dynamic>? ?? {})
          .map((target, item) => MapEntry(target, item as String)));
    for (final item in _pickups.values) {
      _requireItem(item);
    }
    reset();
  }

  int quantity(String itemId) => _inventory[itemId] ?? 0;
  bool hasItem(String itemId, [int count = 1]) => quantity(itemId) >= count;

  void addItem(String itemId, [int count = 1]) {
    final item = _requireItem(itemId);
    if (count <= 0) throw ArgumentError.value(count, 'count');
    _inventory[itemId] = item.permanent ? 1 : quantity(itemId) + count;
  }

  bool removeItem(String itemId, [int count = 1]) {
    final item = _requireItem(itemId);
    if (count <= 0) throw ArgumentError.value(count, 'count');
    if (item.permanent || !hasItem(itemId, count)) return false;
    final remaining = quantity(itemId) - count;
    if (remaining == 0) {
      _inventory.remove(itemId);
    } else {
      _inventory[itemId] = remaining;
    }
    return true;
  }

  bool startQuest(String questId) {
    _requireQuest(questId);
    return _started.add(questId);
  }

  QuestStatus status(String questId) {
    final quest = _requireQuest(questId);
    if (_completed.contains(questId)) return QuestStatus.completed;
    if (!_started.contains(questId)) return QuestStatus.available;
    return quest.requiredItems.entries.every((e) => hasItem(e.key, e.value))
        ? QuestStatus.ready
        : QuestStatus.active;
  }

  bool completeQuest(String questId) {
    final quest = _requireQuest(questId);
    if (status(questId) != QuestStatus.ready) return false;
    for (final entry in quest.requiredItems.entries) {
      removeItem(entry.key, entry.value);
    }
    _completed.add(questId);
    for (final reward in quest.rewards.entries) {
      addItem(reward.key, reward.value);
    }
    return true;
  }

  QuestDefinition? deliverItem(String itemId, String recipient) {
    _requireItem(itemId);
    for (final quest in journal) {
      if (quest.recipient == recipient &&
          quest.requiredItems.containsKey(itemId) &&
          completeQuest(quest.id)) {
        return quest;
      }
    }
    return null;
  }

  bool isPickup(String targetId) => _pickups.containsKey(targetId);
  bool wasCollected(String targetId) => _collected.contains(targetId);

  bool collectPickup(String targetId) {
    final itemId = _pickups[targetId];
    if (itemId == null || !_collected.add(targetId)) return false;
    addItem(itemId);
    return true;
  }

  void reset() {
    _inventory.clear();
    _started.clear();
    _completed.clear();
    _collected.clear();
    for (final item in _items.values.where((item) => item.permanent)) {
      _inventory[item.id] = 1;
    }
  }

  InventoryItemDefinition _requireItem(String id) =>
      _items[id] ?? (throw ArgumentError('Unknown inventory item: $id'));

  QuestDefinition _requireQuest(String id) =>
      _quests[id] ?? (throw ArgumentError('Unknown quest: $id'));
}
