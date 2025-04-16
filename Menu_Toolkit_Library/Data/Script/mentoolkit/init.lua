---@diagnostic disable: missing-fields
---@module "mentoolkit"

local mentoolkit = {
    ---@type mentoolkit.meta.Indexer
    menus = {}
}

local function requireLater(path)
    return function ()
        return require(path);
    end
end

local menuIndexer = {
    loadedMenus = {},
    availableMenus = {
        ['textile'] = requireLater 'mentoolkit.menus.textile',
        ['paginatedOptions'] = requireLater 'mentoolkit.menus.paginated_options'
    }
}
setmetatable(mentoolkit.menus, menuIndexer);

menuIndexer.__index = function (_, index)
    if not menuIndexer.loadedMenus[index] and menuIndexer.availableMenus[index] then
        menuIndexer.loadedMenus[index] = menuIndexer.availableMenus[index]();
    end
    return menuIndexer.loadedMenus[index];
end
--mentoolkit.menus.textile.create(1,2,3,4):CreatePage()

return mentoolkit;