---@meta _

---@class PMDOR.ItemEvent.Target
---@field isItem boolean
---@field isEvent boolean
---@field object any|userdata
---@field Destroy fun()?

---@class PMDOR.ItemEvent.Config
---@field enabled boolean
---@field appearanceChance number A percentage (0.00-1.00) chance to add the effect to an item.
---@field appearanceRules PMDOR.ItemEventRule
---@field modifyRate number A percentage (0.00-1.00) chance to change the effects of an existing item.
---@field disappearanceChance number A percentage (0.00-1.00) chance to remove the effect from an existing item.
---@field settings table