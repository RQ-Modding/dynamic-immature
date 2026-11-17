# Dynamic Immature

Two Special items that give a character the white skill Immature, or take its penalty away.

## What it changes

Immature (HP, Attack and Magic -20%) is in some characters' starting skills, and the game has no
way to change it. This mod adds two items of the Special slot, priced 50,000 Gold:

| Item | Equipped on a character |
| --- | --- |
| **Randoseru** | The character gains Immature. Refused for Rance, for a character who is already Immature, and for one with no free skill slot. |
| **Adult Card** | Immature's penalty is gone. Refused for a character who is not Immature, or whose penalty is already gone. |

- Each works once, the moment it is equipped (from the vault, the status page or the shop). Like
  Rocky Chunk, it vanishes when taken off or replaced, and the effect stays.
- A refused item says why: dropped on a greyed character in the vault, or picked on the status
  page, the game shows the reason ("No free skill slot for Immature.") instead of "Unable to
  equip.".
- **Characters the story presents as children** (Immature from the start: Kouhime, Karma, Reset,
  Onoha, Mill until her story event, and a created character recruited as "still a bit young")
  keep Immature in their skill list: the Adult Card removes only its penalty, and the game's
  scenes and events treat them as before.
- **A character the Randoseru made Immature** is treated by the game as Immature everywhere, scenes
  included, and the Adult Card removes the skill itself.

### Where to get them

- **Before the third world** they are not sold. A chest in the Malgrid Dungeon, from the 5th
  stratum on, holds one very rarely: 0.5% per chest for each item at the 5th stratum, 0.1% more
  each stratum deeper (1% at the 10th), up to 2% in the Xth Stratum.
- **From the third world on**, Frostbuy's Special rack has one of each at every visit.

## With other mods

- **Known Skill Pages:** more skill rows, so the Randoseru finds a free slot more often.
- **Skill Removal Payback, Loadouts:** Immature cannot be erased in the skill window, and a
  Randoseru's Immature was given, not bought: nothing is paid back for it.
- **Morurun's reset and Skill Again** rebuild the starting skills: a story child gets Immature
  back (with the Adult Card's effect kept), and a character the Randoseru made Immature loses it.

## Keys and settings

None.

## Saves

A Randoseru's Immature is the game's own skill and stays without the mod. The Adult Card's effect
on a story child is kept in the mod's data beside the save: without the mod, the penalty comes
back at the character's next stat update. The two items are items of the mod; without it they
show as unknown items.

## Install

Needs [RQ MOD](https://github.com/RQ-Modding/RQ-Mod) with loader **2.55.0** or newer. Extract the
release zip into the game's `mods` folder, so that you have `mods/dynamic-immature/mod.json`.

## How it works

`rq.item.define` makes the two items. `rq.item.on_can_equip` refuses an equip with its reason,
`rq.item.on_equip` gives the effect, `rq.chara.on_has_skill` answers "no" to the stats' check for
Immature on a character whose penalty is gone, `rq.loot.on_pick` puts them in Malgrid chests and
`rq.shop.on_stock` on Frostbuy's rack.

## Credits

The Randoseru's icon, `icons/randoseru.png`, was drawn by Moru for this mod. It is under the mod's
MIT license, like the code.

## License

MIT, see [LICENSE](LICENSE).
