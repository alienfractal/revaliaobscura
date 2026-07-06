# Game Dev Notes

## Entity and Behaviour Architecture

### Why `ActorEntity` was removed

`ActorEntity` was probably introduced to create a general bridge between the game FSM, entity state, model data, and animation handlers.

That idea can be valid when many objects share the same lifecycle, for example:

```text
idle -> walking -> talking -> hurt -> dead -> disabled
```

The problem was that the old `ActorEntity` had become polluted by reused code from another game idea. It mixed generic entity responsibilities with specific legacy board/card concepts such as dirt, relics, floor tiles, bombs, and old rendering rules.

That made the abstraction misleading. It was no longer clearly "an actor"; it had become a generic bucket for unrelated things.

### Current direction

The current design uses composition instead of one large inherited interface.

```text
LevelEntity
  Shared base for interactable things in the level scene.

SailorNpcEntity
  Concrete NPC entity.

WalkingAreaEntity
  Concrete movement target.

MarketBackgroundEntity
  Concrete background visual.

EntityActionBehaviour
  Shared base for reusable action behaviours.
```

Concrete entities declare what they can do through `behaviors: [...]`:

```dart
SailorNpcEntity(...)
  : super(
      dialogueActorId: 'old_sailor',
      behaviors: [
        LookActionBehaviour(dialogId: 'player_error_observe'),
        GrabActionBehaviour(dialogId: 'player_error_interact'),
        TalkActionBehaviour(),
        EntityTapBehaviour(),
      ],
    );
```

This keeps the responsibilities separate:

```text
Entity = what the thing is
Behaviour = what the thing can do
Player selected action = current verb from the UI
Tap behaviour = dispatches the selected verb to the tapped entity
```

### When to reintroduce a stronger actor abstraction

Do not bring back a generic `ActorEntity` just because one entity has animations or dialogue.

Only introduce a narrower actor/NPC abstraction when multiple entities actually share active behaviour, such as:

```text
patrol logic
autonomous decisions
combat state
scheduled dialogue
quest state
shared NPC lifecycle
```

If that happens, prefer a specific name:

```dart
abstract class NpcEntity extends LevelEntity {}
```

or:

```dart
abstract class ActiveLevelEntity extends LevelEntity {
  void updateBrain(double dt);
}
```

The important rule: the abstraction should describe a real shared responsibility in this game, not preserve old reused code.

