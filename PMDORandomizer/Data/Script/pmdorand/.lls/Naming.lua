---@meta _

---@class PMDOR.NamingScheme
---@field names string[]

---@class PMDOR.Naming.Pokemon : PMDOR.NamingScheme
---@field conditions PMDOR.Naming.Pokemon__Conditions

---@class PMDOR.Naming.Pokemon__Conditions
---@field IsSpeciesName string?
---@field Element1 string?
---@field Element2 string?
---@field Species string?

---@class PMDOR.Naming.Moves : PMDOR.NamingScheme
---@field conditions PMDOR.Naming.Moves__Conditions

---@class PMDOR.Naming.Moves__Conditions
---@field Element string?