---@meta _

---@class PMDOR.Conf.Set
---@field enabled boolean
---@field randomizationChance number A random percentage (0.00-1.00) rolled to determine if randomization should succeed.

---@class PMDOR.Conf.ItemEffect
---@field enabled boolean
---@field appearanceChance number A random percentage (0.00-1.00) rolled to determine if the effect should be allowed to appear.
---@field appearanceRules PMDOR.ItemEventRule Flags controlling whether the effect should be allowed to appear on an item.
---@field disappearanceChance number A random percentage (0.00-1.00) rolled to determine if the effect should be removed.

---@class PMDOR.Conf.HealthRestoration : PMDOR.Conf.ItemEffect
---@field flatHealing boolean
---@field minHealed number
---@field maxHealed number