# Dialogue Graphs

Dialogue graph JSON files define conversation structure independently from
translated text.

The plain-Dart progression state machine lives in `lib/dialoguefsm`, alongside
the project's other root FSM folders. It owns actor profiles, active
conversation sessions, node traversal, story flags, and one-time responses.
`DialogueManager` is the Flutter-facing adapter responsible for loading assets
and forwarding dialogue events to the renderer.

The top-level `actors` object maps stable in-game NPC IDs to translated names
and ordered conversation entrypoints:

```json
{
  "actors": {
    "old_sailor": {
      "id": "old_sailor",
      "name_key": "actors.old_sailor.name",
      "entrypoints": [
        {
          "dialogue": "npc_after_identity",
          "when": {
            "flag": "sailor_identity_known"
          }
        },
        {
          "dialogue": "npc_intro"
        }
      ]
    }
  }
}
```

Scene construction identifies an NPC by its stable actor ID. The dialogue
progression FSM selects the first eligible entrypoint. Put conditional
entrypoints before the unconditional fallback.

Each node under `dialogues` may contain:

- `event`: optional event emitted when the node starts
- `responses`: the available player choices
- `responses[].next`: the next node ID, or `end` to close the conversation
- `responses[].event`: optional event emitted when the response is chosen
- `responses[].when`: optional story-state condition
- `responses[].effects`: optional story-state changes applied when selected
- `responses[].once`: hides a response after the player selects it

Supported conditions are `flag`, `all`, `any`, and `not`. A flag condition may
use `equals: false`. Effects currently support `set_flag` with an optional
boolean `value`.

Story flags and one-time responses survive between conversations during a
playthrough. Call `DialogueManager.resetProgress()` when starting a new game.

Visible text belongs in `resources/translations/<locale>.json` using the same
node IDs and response order. Actor display names also belong in translations.
The game validates actor profiles and missing `next` targets when it loads the
graph.
