# Testing Dynamic Immature

For people and agents who test the mod in the game. Read it before you use anything the mod adds.
Assume nothing about the mod when it is not installed: check `logs\rqmod.log` for
`Loading dynamic-immature` and the line `dynamic-immature: Randoseru <no>, Adult Card <no>`.

## What it adds

- **Items** (Special slot, price 50,000, vanish when taken off):
  - `dynamic-immature:randoseru`, "Randoseru", the mod's icon `icons/randoseru.png`.
  - `dynamic-immature:adult-card`, "Adult Card", the FastPass's CG 6331.
- **Equip rules** (`rq.item.on_can_equip`), each with the text the game then shows:
  - Randoseru on Rance (character 1): "Rance won't be caught dead wearing a school bag."
  - Randoseru on a character who holds Immature (skill 373): "<name> is already Immature."
  - Randoseru with `rq.chara.skill_room` 0: "No free skill slot for Immature."
  - Adult Card on a character without Immature: "<name> is not Immature."
  - Adult Card on a story child whose penalty is already gone: "Immature's penalty is already gone."
- **Where the text shows:** a drop on a greyed character row of the vault's equip list
  (`equip-drag`) shows it in the game's notice instead of "Unable to equip.". On the status page's
  item list such an item is not greyed: picking it shows the text and equips nothing. Close the
  notice with its OK.
- **Effects** (`rq.item.on_equip`, the moment the item is put on):
  - Randoseru: skill 373 granted, stats worked out again (max HP, Attack and Magic x 0.8).
  - Adult Card on a story child (373 in `rq.chara.base_skills`): 373 stays, the -20% is gone; the
    roster slot and character number go in `rq.savedata` key `grown`.
  - Adult Card on anyone else: 373 erased (`rq.chara.forget`), stats back.
- **Chests:** in the Malgrid Dungeon from the 5th stratum, the chest's pick is replaced with each
  item at 0.5% + 0.1% per stratum past the 5th (`rate_at`), the Xth Stratum counted as 10 + its
  stratum, at most 2%. Log line `dynamic-immature: a Randoseru in a chest (<rate>%)`.
- **Frostbuy:** from world 3 (`rq.world.current()`), one of each on sale at every visit; before,
  none.

No controls, keys or settings. Do not invent other controls.

## How to check it

1. Give a Randoseru (`rq.item.give("dynamic-immature:randoseru")`) and equip it on an adult with a
   free skill row: Immature is in the skill list, max HP, Attack and Magic drop by 20%. Take it
   off: the item is gone, Immature stays.
2. Equip a Randoseru on Rance, on an Immature character and on a character with a full list: each
   is refused with its text, in the vault and on the status page.
3. Equip an Adult Card on that adult: Immature is erased, the stats are back.
4. Equip an Adult Card on a story child (Kouhime, 20): Immature stays in the list, the stats are
   those without it. A scene check (`ＣＳ有無(iic, 373, 0)` from any function but `Ｃ再計算`) still
   finds it. Save, load: still no penalty.
5. In world 3, open Frostbuy: both items are on sale at 50,000.

## Forcing it for a test

`rq.mod.get("dynamic-immature")` returns `RANDOSERU`, `CARD` (the item numbers), `IMMATURE`,
`is_grown(iic)`, `story_child(iic)`, `rate_at(depth)`, `depth_now()`, `set_rate(pct)`, which
sets the chance per chest for each item (100 makes every qualifying chest give a Randoseru; nil
puts the mod's own back; it still needs a Malgrid stratum of 5 or deeper), and `ungrow(iic)`,
which undoes the Adult Card on a story child (the penalty comes back).

## Tested in the game

The Test Lab's scenario `dynamic-immature` (with this mod installed): both items on a story child, an adult and a full
list; the refusal texts in the vault and on the status page; the stats; a scene's check still
finding Immature; the vanish on removal; a save and a load; a Malgrid chest; Frostbuy in world 3;
Rance refused.
