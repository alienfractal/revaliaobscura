from pathlib import Path
S=Path(__file__).resolve().parent/'.forest-mushrooms-work'
p=S/'resources/dialogues/INK_DEMO.md'
t=p.read_text(encoding='utf-8')
start=t.index('7. Talk to the mushroom')
end=t.index('9. Return via',start)
t=t[:start]+'''7. The tall green-capped wise mushroom explains that Metsavana is in a trance,
   tended by the gnomes, and points out the purple mushroom. Its dialogue never
   awards ink. Touch the purple mushroom to receive one bottle of usable ink and
   250 points immediately, without a dialogue choice. An empty bottle is optional;
   if already carried it is reused. Further touches never duplicate ink or score.
8. The small knife-carrying mushroom fears basket-carrying locals and asks whether
   you eat mushrooms. Answering no is safe. Answering yes plays its attack once,
   followed by the player's existing death animation and game-over flow. This
   does not use the old poisoning/retry branch.
'''+t[end:]
t+='''
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
'''
p.write_text(t,encoding='utf-8')
p=S/'resources/dialogues/INVENTORY_AND_QUESTS.md'
t=p.read_text(encoding='utf-8')
t=t.replace('The forest dialogue consumes this bottle and awards `ink_bottle` once. There\nis no loose ink pickup in town.',
'''Touching the forest's purple mushroom awards `ink_bottle` once and sets
`forest_ink_collected`. It reuses an empty bottle if carried but does not require
one. The wise mushroom provides directions only; the knife mushroom's fatal
dialogue is separate. There is no loose ink pickup in town.''')
p.write_text(t,encoding='utf-8')
print('Updated quest documentation for the three forest mushrooms.')
