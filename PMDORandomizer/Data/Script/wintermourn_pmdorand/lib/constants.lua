---@class Color : any
---@class Loc
---@class CSObject : any

local CONST = {
    FUNCTION_EMPTY = function () end,
    REQUIRE_LATER = function (modname) return function() return require(modname) end end,
    PERFORM_LATER = function (modname) return function(...) return require(modname)(...) end end,
    ---@param modname string
    ---@param ... any The path inside the returned value, assuming a table, to follow and execute like a function.
    ---@return function
    PERFORM_INSIDE_LATER = function (modname, ...)
        local path = {...}
        return function(...)
            local r = require(modname);
            for _,k in pairs(path) do r = r[k] end

            return r(...);
        end
    end,
    Classes = {
        System = {
            Convert = luanet.import_type('System.Convert'),
            Object = luanet.import_type('System.Object'),
            BindingFlags = luanet.import_type('System.Reflection.BindingFlags'),
            Linq = {},
            Type = luanet.import_type('System.Type'),
            IO = luanet.namespace('System.IO')
        },
        Xna = {
            Keys = luanet.import_type('Microsoft.Xna.Framework.Input.Keys')
        }
    },
    Enums = {
        ---@enum System.Reflection.BindingFlags
        BindingFlags = {
            NonPublic = 32,
            Instance  = 4,
            Public = 16,
            Static  = 8,
            ---@type fun(integer): CSObject
            Convert = nil
        }
    },
    Functions = {
        CLOSE_MENU = function () _MENU:RemoveMenu() end,
        Menu = {}
    },
    Methods = {
        ---@type fun(x: integer, y: integer): Loc
        Location = RogueElements.Loc,
        Menu = {
            MenuText = RogueEssence.Menu.MenuText,
            Elements = {
                ---@type fun(text: string, callback: fun())
                TextChoice = RogueEssence.Menu.MenuTextChoice,
                ---@type fun(text: string, callback: fun())
                ElementChoice = RogueEssence.Menu.MenuElementChoice,
                ---@type fun(loc: Loc, length: integer)
                Divider = RogueEssence.Menu.MenuDivider
            }
        },
        System = {Linq = {Enumerable = {
            ---@type fun(generic, enumerable: any): any
            ToArray = nil
        }}}
    }
};
local System = CONST.Classes.System;

--[[ CONST.Enums.BindingFlags.NonPublic = System.Convert.ToInt32(System.BindingFlags.NonPublic);
CONST.Enums.BindingFlags.Instance = System.Convert.ToInt32(System.BindingFlags.Instance); ]]
CONST.Enums.BindingFlags.Convert = function (integer) return LUA_ENGINE:LuaCast(integer, System.BindingFlags); end

-- Linq strangling (Static classes won't import through luanet.import_type, so i'm going through drastic measures)
System.Linq.Enumerable = System.Type.GetType("System.Linq.Enumerable, System.Linq, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089");
CONST.Methods.System.Linq.Enumerable.ToArray = function(generic, enumerable)
    return System.Linq.Enumerable:GetMethod(
        "ToArray",
        CONST.Enums.BindingFlags.Convert(CONST.Enums.BindingFlags.Public | CONST.Enums.BindingFlags.Static)
    ):MakeGenericMethod(generic):Invoke(nil, luanet.make_array(System.Object, {enumerable}));
end

return CONST;