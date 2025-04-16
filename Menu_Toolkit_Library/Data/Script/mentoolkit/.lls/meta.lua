---@meta _

---@class mentoolkit.Menu

---@class mentoolkit.MenuControls
---@field create fun(x: integer, y: integer, w: integer, h: integer): mentoolkit.Menu
---@field __metatables table

---@class mentoolkit.meta.Indexer
---@field textile mentoolkit.MenuControls<mentoolkit.Textile>|{create: fun(x: integer, y: integer, w: integer, h: integer): mentoolkit.Textile}
---@field paginatedOptions mentoolkit.MenuControls<mentoolkit.PaginatedOptions>|{create: fun(x: integer, y: integer, w: integer, h: integer): mentoolkit.PaginatedOptions}