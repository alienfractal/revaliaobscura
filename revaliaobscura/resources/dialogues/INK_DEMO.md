# Ink quest demo

The demo uses the existing game state and `GameboardView`. Three location VIEWs,
`CityGatesView`, `RiverCrossingView` and `ForestView`, share its gameplay and HUD. Changing VIEW
preserves `StoryState`, inventory, pickup history, and `GameBoardModel` scores.
A new game still starts in town and clears progress through the existing menu.

## Playthrough

1. Talk to Hendrik, learn his name, ask what he needs, and accept the ink quest.
2. The lady now answers. Explain the ink request; she recommends the city guard.
3. Talk to the guard after getting the lady's directions. Accept his permission
   to pass; the conversation transitions directly to the city-gates VIEW.
4. Touch the empty bottle beside the drunk count in the street by the gates.
   It enters inventory once. The count has no dialogue tree: Talk produces a
   brief slurred reply, described as incoherent Livonian rather than a translation.
5. Take To river, then To forest. The unlocked town exit also leads to the gates.
6. Talking to Metsavana gives silence and a hint toward the talking mushroom.
7. The tall green-capped wise mushroom explains that Metsavana is in a trance,
   tended by the gnomes, and points out the purple mushroom. Its dialogue never
   awards ink. Touch the purple mushroom to receive one bottle of usable ink and
   250 points immediately, without a dialogue choice. An empty bottle is optional;
   if already carried it is reused. Further touches never duplicate ink or score.
8. The small knife-carrying mushroom fears basket-carrying locals and asks whether
   you eat mushrooms. Answering no is safe. Answering yes plays its attack once,
   followed by the player's existing death animation and game-over flow. This
   does not use the old poisoning/retry branch.
9. Return via To river, To gates, To town. Give Hendrik the ink through dialogue or by
   using it from inventory. Both paths consume ink and award one Tallinn-Tartu
   map. Completion awards 500 points once. The map remains in inventory; its
   Look/Touch descriptions explain the reward while its final drawing is pending.

There is no countdown during this exploration quest. Existing energy, combat
death, and other game screens are otherwise retained.

## Artwork handoff

Scene placement, clickable sizes, walking polygons, and arrivals are in:

- `resources/scenarios/town_square.json`
- `resources/scenarios/city_gates.json`
- `resources/scenarios/river_crossing.json`
- `resources/scenarios/forest.json`

The guard reuses the sailor sprite and talking animation, but has a separate
actor ID (`city_guard`) and independent dialogue. The forest uses
`forest-background-320x200-1.png`, and Metsavana still uses temporary scene art. The
background renderer uses whole-number scaling with padding to preserve pixels.

The forest's `foreground` points to
`forest-background-plants-front-320x200-1.png`. This transparent 320 x 39 plant
strip is bottom-aligned at (0, 161) in the 320 x 200 VIEW, at priority 1000:
above depth-sorted characters and objects, below dialogue and HUD. It does not
intercept clicks. The background's actual exported size is 320 x 179 and is
displayed without stretching. Other scenarios may omit `foreground`.

The bottle and mushrooms use labelled temporary markers. Replace their
`asset_id` values (`placeholder:...`) with a PNG path under `resources/images/`.
Keep `interaction_id` and `dialogue_actor_id` unchanged. Set `size` to the
desired logical dimensions and adjust `feet_position` to position the art.
The bottle has its own marker beside the count so only the bottle disappears.
The gates background is `RevalGates320x200-1.png` at its authored 320 x 200 size.
The count uses `drunk-count-reduced-57x84-7.png`. Its actual export is 224 x 82,
so each of its seven source frames is 32 x 82 and is displayed without stretching.

### Custom frame order

Any `animation` or `talk_animation` may include a one-based `sequence` list.
Without it, all source frames play in order. Repeated numbers extend a pose.
The count uses this exact loop at 0.2 seconds per entry (six seconds total):

```json
"animation": {
  "frames": 7, "width": 32, "height": 82, "step_time": 0.2,
  "sequence": [1,1,1,2,3,5,6,7,5,6,7,5,6,7,1,2,3,4,5,2,2,2,2,1,2,3,4,5,6,7]
}
```

Edit the sequence or `step_time` in `city_gates.json` to tune playback. Frame
numbers outside 1 through `frames`, empty sequences, and invalid timing fail
clearly rather than sampling the wrong part of a sprite sheet.

`quest_prop` supports a static PNG or an animation strip, including an optional
separate talking strip. For example, to connect your mushroom animation:

```json
{
  "asset_id": "resources/images/mushroom-idle.png",
  "talk_asset": "resources/images/mushroom-talk.png",
  "talk_animation": {"frames": 4, "width": 32, "height": 30, "step_time": 0.15}
}
```

Use the same `animation` structure for an idle animation, including Metsavana's
blink or the gnome's work/breath cycle. All strips run left to right. The current
gnome slot uses the existing 32 x 30 work/breath strip at its authored pixel size.
The mushroom talk strip was not found among the current exported assets.

Inventory definitions are in `revalia_dialogues.json` under `inventory_items`.
Add an `icon` PNG path to `empty_bottle`, `ink_bottle`, and `tartu_route_map` when
those drawings are ready. Until then the existing inventory placeholders apply.

New dialogue wording is in English translations; the current fallback supplies
it for other languages. Existing translated Hendrik lines may need updating
later to mention the Tartu map.

## Verification

`flutter test --no-pub` covers dialogue gates, the full successful route, missing
bottle, stale/double collection, inventory delivery, one-time rewards, reset,
connected travel, and actual mounted VIEW travel/death/retry/delivery.
The VIEW test writes rendered checks to `build/quest-previews/`.

The final bottle, mushroom, blink and map artwork still need an artist's
pass before this is a finished visual demo. Existing sound assets are reused.

## Forest mushroom artwork and interaction

- Knife mushroom: `00054-mush3-sheet_32x51-9.png`, 9 horizontal frames,
  each 32 pixels wide and 51 pixels tall. Idle loops; the attack plays once.
- Wise mushroom: `forest-mushroom-2-sheet_88x128-19.png`, 19 horizontal
  frames, each 88 pixels wide and 128 pixels tall. Displayed at 44 × 64;
  its animation speeds up while speaking.
- Purple ink mushroom: `forest-mushroom-talk-purple-sheet_50x52-10.png`,
  10 horizontal frames, each 50 pixels wide and 52 pixels tall. Displayed at
  25 × 26; touching it awards ink once and leaves the mushroom in the scene.

All three use depth sorting without perspective scaling. The forest background,
Metsavana, gnomes, exits and river-crossing scene are retained. New dialogue and
interaction messages are supplied in English, Spanish and Estonian.
