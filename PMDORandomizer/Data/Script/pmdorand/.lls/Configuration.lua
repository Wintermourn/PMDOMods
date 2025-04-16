---@meta _

---@class PMDOR.Conf.Set
---@field enabled boolean
---@field randomizationChance number A random percentage (0.00-1.00) rolled to determine if randomization should succeed.

---@class PMDOR.Conf.ItemEffect
---@field enabled boolean
---@field appearanceChance number A random percentage (0.00-1.00) rolled to determine if the effect should be allowed to appear.
---@field appearanceRules PMDOR.ItemEventRule Flags controlling whether the effect should be allowed to appear on an item.
---@field disappearanceChance number A random percentage (0.00-1.00) rolled to determine if the effect should be removed.

---@class PMDOR.ConfigTemplate : {PMDOR.ConfigTemplate.Table|PMDOR.ConfigTemplate.String|PMDOR.ConfigTemplate.Percentage|PMDOR.ConfigTemplate.Integer|PMDOR.ConfigTemplate.Toggle}

---@class PMDOR.ConfigTemplate.Table
---@field type 'table'
---@field value table

---@class PMDOR.ConfigTemplate.Subtable
---@field type 'subtable'
---@field value PMDOR.ConfigTemplate

---@class PMDOR.ConfigTemplate.String
---@field id string
---@field type 'string'
---@field default string
---@field minLength integer?
---@field maxLength integer?
---@field maxCharacters integer?

---@class PMDOR.ConfigTemplate.Percentage
---@field id string
---@field type 'percent'
---@field default number
---@field stepSize number
---@field minValue number?
---@field maxValue number?

---@class PMDOR.ConfigTemplate.Integer
---@field id string
---@field type 'int'
---@field default integer
---@field jumpSize integer?
---@field minValue integer?
---@field maxValue integer?

---@class PMDOR.ConfigTemplate.Number
---@field id string
---@field type 'number'
---@field default number
---@field stepSize number
---@field minValue number?
---@field maxValue number?

---@class PMDOR.ConfigTemplate.Toggle
---@field id string
---@field type 'toggle'
---@field default boolean