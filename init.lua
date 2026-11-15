-- Dynamic Immature: two Special items. The Randoseru gives its wearer the white skill Immature; the
-- Adult Card takes Immature's penalty away. Each works once, when it is equipped, and vanishes when
-- it is taken off; the effect stays.
--
-- Characters the story presents as children (Immature in their starting set) keep the skill: the
-- Adult Card only removes its -20% to max HP, Attack and Magic, so every scene and condition of the
-- game still sees them as Immature, with or without this mod. A character the Randoseru made
-- Immature loses the skill for good.
--
-- Before the third world both items come only from chests in the Malgrid Dungeon, from the 5th
-- stratum on; from the third world on, Frostbuy sells both.
-- Loader 2.55.0: rq.item.on_equip, a refusal's text from rq.item.on_can_equip and
-- rq.chara.on_has_skill.

if not (rq.item.on_equip and rq.chara.on_has_skill) then
  error("dynamic-immature: loader 2.55.0 or newer needed")
end

local IMMATURE = 373       -- the white skill "Immature" (HP, Attack and Magic -20%)
local RANCE = 1            -- character number
local PRICE = 50000
local SHOP = 6
local MALGRID_X = 147      -- the Xth Stratum: its strata count on past the 10th
local FIRST_DEPTH = 5      -- the first stratum that drops them
local RATE_FIRST = 0.5     -- percent per chest for each item at the 5th stratum
local RATE_STEP = 0.1      -- and this much more each stratum deeper
local RATE_MAX = 2.0

local RANDOSERU = rq.item.define({
  id = "dynamic-immature:randoseru",
  name = "Randoseru",
  type = "special",
  icon = "icons/randoseru.png",
  price = PRICE,
  vanishes = true,
  -- Three lines fit a vault row, which adds "Will disappear when removed." itself.
  info = "A sturdy school bag that survives recess.$Equip: the wearer gains Immature.$"
    .. "Needs a free skill slot. Immature stays.",
})

local CARD = rq.item.define({
  id = "dynamic-immature:adult-card",
  name = "Adult Card",
  type = "special",
  icon = 6331,
  price = PRICE,
  vanishes = true,
  info = "Nobody believes it, but the stats do.$Equip: Immature's penalty is gone; a$"
    .. "Randoseru's Immature goes for good.",
})

-- Characters --------------------------------------------------------------------------------------

local function chara_no(iic)
  local ok, c = pcall(rq.ain.global, "Ｃ", iic, "番号")
  return ok and math.type(c) == "integer" and c or 0
end

local function name_of(iic)
  local ok, c = pcall(rq.chara.get, iic)
  return ok and type(c) == "table" and c.name or "This character"
end

-- Holds Immature now (the game's own check; this mod answers "no" only inside the stats).
local function immature(iic)
  local ok, row = pcall(rq.ain.call, "ＣＳ有無", iic, IMMATURE, 0)
  return ok and math.type(row) == "integer" and row ~= 0
end

-- Immature is in the starting set: a character the story presents as a child.
local function story_child(iic)
  local ok, set = pcall(rq.chara.base_skills, iic)
  if not ok or type(set) ~= "table" then return true end -- in doubt, keep the skill
  for _, s in ipairs(set) do
    if s.id == IMMATURE then return true end
  end
  return false
end

-- The story children whose penalty the Adult Card removed, in the save: roster slot (as text) to
-- character number, so another character in that slot later is not one of them.
local grown = nil

local function grown_map()
  if not grown then
    local ok, v = pcall(rq.savedata.get, "grown", {})
    grown = ok and type(v) == "table" and v or {}
  end
  return grown
end

local function is_grown(iic, no)
  local c = grown_map()[tostring(iic)]
  return c ~= nil and c == (no or chara_no(iic))
end

local function set_grown(iic, on)
  local m = grown_map()
  m[tostring(iic)] = on and chara_no(iic) or nil
  rq.savedata.set("grown", next(m) and m or nil)
end

-- The game works out the stats in Ｃ再計算, which applies the penalty when ＣＳ有無 finds Immature:
-- for a grown character, that one check is told "no". Scenes and conditions still see the skill.
rq.chara.on_has_skill(IMMATURE, function(ctx)
  if is_grown(ctx.iic, ctx.chara) and ctx.caller == "Ｃ再計算" then return false end
end)

local function recalc_grown()
  for key, no in pairs(grown_map()) do
    local iic = math.tointeger(tonumber(key))
    if iic and chara_no(iic) == no then pcall(rq.chara.recalc, iic) end
  end
end

rq.saves.on_load(function()
  grown = nil
  recalc_grown()
end)

rq.on_reset(function()
  grown = nil
end)

-- Equipping -----------------------------------------------------------------------------------------

rq.item.on_can_equip(function(ctx)
  local no = ctx.no
  if no == RANDOSERU then
    if ctx.chara == RANCE then return false, "Rance won't be caught dead wearing a school bag." end
    if immature(ctx.iic) then return false, name_of(ctx.iic) .. " is already Immature." end
    local ok, room = pcall(rq.chara.skill_room, ctx.iic)
    if ok and room < 1 then return false, "No free skill slot for Immature." end
  elseif no == CARD then
    if not immature(ctx.iic) then return false, name_of(ctx.iic) .. " is not Immature." end
    if is_grown(ctx.iic, ctx.chara) then return false, "Immature's penalty is already gone." end
  end
end)

rq.item.on_equip(function(ctx)
  local iic = ctx.iic
  if ctx.no == RANDOSERU then
    if immature(iic) then return end
    rq.chara.grant(iic, IMMATURE, 0)
    rq.chara.recalc(iic)
    rq.log(("dynamic-immature: %s is Immature (Randoseru)"):format(name_of(iic)))
  elseif ctx.no == CARD then
    if not immature(iic) then return end
    if story_child(iic) then
      set_grown(iic, true)
      rq.chara.recalc(iic)
      rq.log(("dynamic-immature: %s keeps Immature, its penalty gone (Adult Card)"):format(name_of(iic)))
    else
      rq.chara.forget(iic, IMMATURE)
      rq.chara.recalc(iic)
      rq.log(("dynamic-immature: %s is no longer Immature (Adult Card)"):format(name_of(iic)))
    end
  end
end)

-- Malgrid Dungeon chests ------------------------------------------------------------------------------

local rate_override = nil -- for a test: percent per chest for each item

-- How deep the party is in the Malgrid Dungeon: the stratum, the Xth Stratum's past the 10th.
local function depth_now()
  local ok, info = pcall(rq.dungeon.info)
  if not ok or type(info) ~= "table" or not info.stratum then return nil end
  if info.quest == MALGRID_X then return 10 + info.stratum end
  return info.stratum
end

-- The percent per chest for each item at a depth: 0.5 at the 5th stratum, 0.1 more per stratum.
local function rate_at(depth)
  if not depth or depth < FIRST_DEPTH then return 0 end
  return math.min(RATE_FIRST + RATE_STEP * (depth - FIRST_DEPTH), RATE_MAX)
end

local function in_chest()
  local ok, st = pcall(rq.ain.stack, 8)
  if not ok or type(st) ~= "table" then return false end
  for _, n in ipairs(st) do
    if n == "宝箱の中身生成" then return true end
  end
  return false
end

-- A chest tries its pools in turn until one gives an item, so the pick with an item is the chest's:
-- one roll per chest.
rq.loot.on_pick(function(ctx)
  if ctx.item == 0 then return nil end
  local rate = rate_at(depth_now())
  if rate <= 0 or not in_chest() then return nil end
  rate = rate_override or rate
  local r = math.random() * 100
  if r < rate then
    rq.log(("dynamic-immature: a Randoseru in a chest (%.1f%%)"):format(rate))
    return RANDOSERU
  elseif r < 2 * rate then
    rq.log(("dynamic-immature: an Adult Card in a chest (%.1f%%)"):format(rate))
    return CARD
  end
  return nil
end)

-- Frostbuy ----------------------------------------------------------------------------------------------

-- From the third world on, one of each on the rack at every visit; none before.
rq.shop.on_stock(function()
  local world = rq.world.current() or 1
  for _, no in ipairs({ RANDOSERU, CARD }) do
    if world >= 3 then
      if not rq.shop.in_stock(no) then rq.shop.stock(no) end
    else
      for _, ii in ipairs(rq.item.find(no, { place = SHOP })) do rq.item.remove(ii) end
    end
  end
end)

rq.log(("dynamic-immature: Randoseru %d, Adult Card %d"):format(RANDOSERU, CARD))

-- For the Lab and other mods.
return {
  RANDOSERU = RANDOSERU,
  CARD = CARD,
  IMMATURE = IMMATURE,
  is_grown = is_grown,
  story_child = story_child,
  rate_at = rate_at,
  depth_now = depth_now,
  -- A test's chance per chest for each item, in percent; nil puts the mod's own back.
  set_rate = function(pct) rate_override = pct end,
  -- A test's undo of the Adult Card on a story child: the penalty comes back.
  ungrow = function(iic)
    set_grown(iic, false)
    pcall(rq.chara.recalc, iic)
  end,
}
