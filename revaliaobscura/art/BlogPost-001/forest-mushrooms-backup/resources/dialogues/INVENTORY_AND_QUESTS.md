# Inventory and quests

See [Ink quest demo](INK_DEMO.md) for the connected town, gates, river, and forest
VIEWs, the empty-bottle-to-ink interaction, poisoning retry, and art slots.

The HUD inventory button opens a modal popup. World movement, animations, and
the level timer pause while it is open. Opening it cancels queued walking or
interactions. Finish the current dialogue before opening inventory.

The popup is a five-column, two-row grid of item slots, matching the HUD's
point-and-click interaction model. Choose an action with the existing top HUD
buttons, then click an item. The HUD stays clickable while the scene is paused:

- **Look** displays the item's description.
- **Touch** opens the task scroll's journal, or selects a usable item and closes
  inventory. Dismiss the hint, then touch a scene target to use that item.
- **Talk** displays the item's `talk` text, or a default response.
- **Walk** displays the item's `walk` text, or "I cannot walk on this."

Empty slots do nothing. Inventory preserves the active HUD action. Choosing a
usable item with Touch uses the existing hand action for its scene target.
An unsuccessful use keeps the item, and choosing another HUD action cancels
item selection. Non-usable items display their `touch` text instead.

Touching the permanent yellow task scroll opens the journal with current and completed
quests. Item lists and journal text have page arrows when needed. The scroll
cannot be consumed or removed.

Progress survives conversations and scene rebuilds within a playthrough.
Starting a new game clears items, pickup history, flags, and quests, then restores
the scroll. Disk saves are not part of this system.

## UI and artwork

`lib/game/states/level_game/view/game_board_ui_comp_handler.dart` owns the HUD
button position and shared `actionButtonSize` (24 x 24 logical units). Inventory
uses the same size and center alignment as Walk, Talk, Touch, and Look. Its
position is relative to the camera's right edge, and the energy bar sits to its
left. `FixedResolutionViewport` in `lib/revalia_obs.dart` scales the HUD with
the window while preserving proportions.

`lib/game/states/level_game/view/inventory_popup.dart` owns the popup dimensions,
placeholder item tiles, and scroll drawing. The inventory button uses
`resources/images/action-icon-inventory-24x24.png`. The popup uses the
320 x 200 viewport.

An item's optional `icon` is a PNG asset path used for its inventory tile.
Items without an icon use a placeholder; the task scroll has a yellow drawing.

## Item and quest definitions

The top-level lists in `revalia_dialogues.json` are the source of truth:

```json
{
  "inventory_items": {
    "task_scroll": {"permanent": true, "usable": false},
    "ink_bottle": {"usable": true}
  },
  "quests": {
    "navigator_ink": {
      "recipient": "old_sailor",
      "required_items": {"ink_bottle": 1}
    }
  },
  "pickups": {
    "empty_bottle_pickup": "empty_bottle"
  }
}
```

`recipient` is the scene entity's `interaction_id`. Each quest may require
several items and quantities. Quest status is:

- `available`: not accepted; hidden from the journal.
- `active`: accepted, but required items are missing.
- `ready`: accepted and all required items are held.
- `completed`: delivered; remains in the journal.

Finding ink alone does not finish the task. Delivery checks the recipient and
all required quantities, consumes the requirements once, and marks it completed.
Restarting an accepted or completed quest does not duplicate it.

## Dialogue hooks

Use these response effects:

```json
{"start_quest": "navigator_ink"}
{"add_item": "ink_bottle", "quantity": 1}
{"complete_quest": "navigator_ink"}
```

`complete_quest` requires a ready quest and consumes its required items. Gate
the response with a condition:

```json
{"quest": "navigator_ink", "status": "ready"}
{"has_item": "ink_bottle", "quantity": 1}
```

These work inside existing `all`, `any`, and `not` conditions as well.
Keep conditional actor entrypoints above their fallback.

The sailor's existing acceptance response now starts `navigator_ink`. Once
ready, his waiting dialogue offers **Here is the ink you asked for**. Delivery
through dialogue and delivery through inventory use the same quest state.
After completion his entrypoint selects a thank-you dialogue.

## Placing the bottle

The city-gates scenario places an empty-bottle pickup beside the drunken count.
Replace its temporary marker with final artwork in the scenario JSON, keeping
its interaction ID. A static prop example is:

```json
{
  "type": "static_prop",
  "asset_id": "resources/images/empty-bottle.png",
  "interaction_id": "empty_bottle_pickup",
  "feet_position": [160, 160],
  "size": [16, 16],
  "walkable": false,
  "perspective_scaling": true,
  "depth_sorting": true
}
```

The coordinates above are an example. The `pickups` mapping already connects
this interaction ID to `empty_bottle`. Touching a pickup approaches it, adds one
item, and removes the prop. Collected props stay absent after rebuilding the
scene, including after delivering their item. Use unique interaction IDs for
separate pickup sources. Existing animated props can also serve as pickups.
The forest dialogue consumes this bottle and awards `ink_bottle` once. There
is no loose ink pickup in town. Quest completion awards `tartu_route_map` through
the quest definition's `rewards`, both for dialogue and inventory delivery.

To award an item from other game logic, call:

```dart
DialogueManager.fsm.storyState.adventure.addItem('ink_bottle');
```

For a quick ink-flow check before placing art, use the `add_item` response effect
in a temporary dialogue. Remove that temporary award before shipping.

## Visible text

Text belongs in `resources/translations/<locale>.json`:

- `items.<id>.name`, `.look`, `.touch`, plus optional `.talk` and `.walk`
- `quests.<id>.title`, `.description`, `.completed`
- `inventory.*` for popup controls and status messages

English text is supplied and serves as the existing fallback for other locales.
World Look reactions still use `objects.<interaction_id>.actions` and `messages`,
as described in `README.md` in this folder.

Inventory/quest rules live in `lib/dialoguefsm/adventure_state.dart`, the dialogue
bridge in `story_state.dart`, and scene interaction hooks in `level_entity.dart`.
