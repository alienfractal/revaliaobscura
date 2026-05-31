# Dialogue Graphs

Dialogue graph JSON files define conversation structure independently from
translated text.

Each node under `dialogues` may contain:

- `event`: optional event emitted when the node starts
- `responses`: the available player choices
- `responses[].next`: the next node ID, or `end` to close the conversation
- `responses[].event`: optional event emitted when the response is chosen

Visible text belongs in `resources/translations/<locale>.json` using the same
node IDs and response order. The game validates missing `next` targets when it
loads the graph.
