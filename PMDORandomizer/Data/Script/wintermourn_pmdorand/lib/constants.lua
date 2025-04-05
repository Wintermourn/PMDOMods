---@class Color : any
---@class Loc
---@class CSObject : any

local CONST = {
    FUNCTION_EMPTY = function () end,
    REQUIRE_LATER = function (modname) return function() return require(modname) end end,
    PERFORM_LATER = function (modname) return function(...) return require(modname)(...) end end,
    INVOKE = function (func) return function(...) return func(...) end end,
    INVOKE_WITH = function (func, self) return function(...) return func(self, ...) end end,
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
            String = luanet.import_type('System.String'),
            Convert = luanet.import_type('System.Convert'),
            Object = luanet.import_type('System.Object'),
            Array = luanet.import_type('System.Array'),
            BindingFlags = luanet.import_type('System.Reflection.BindingFlags'),
            Linq = {},
            Type = luanet.import_type('System.Type'),
            IO = luanet.namespace('System.IO'),
            Environment = luanet.import_type('System.Environment')
        },
        Xna = {
            Keys = luanet.import_type('Microsoft.Xna.Framework.Input.Keys')
        }
    },
    PMDCDat = {
        Events = {
            HealthAffecting = {
                RestoreHPEvent = luanet.ctype(PMDC.Dungeon.RestoreHPEvent)
            },
            StomachAffecting = {
                RestoreBellyEvent = luanet.ctype(PMDC.Dungeon.RestoreBellyEvent)
            }
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
        },
        ---@enum PMDOR.ItemEventRule
        ItemEventRule = {
            DENIED = 0,
            --- The item has known positive effects.
            RECOVERY    = 1,
            --- The item has known negative effects.
            HARMFUL     = 2,
            --- Denies items that can be used/consumed (e.g. berries)
            EXCLUDE_USABLE = 4,
            --- Denies items that are equipped/held (e.g. Mobile Scarf)
            EXCLUDE_EQUIPMENT = 8
        },
        EventType = {
            INSTANT     = 1
        },
        ---@enum PMDOR.PriceMode
        PriceMode = {
            RAWRANDOM       = 0,
            RANDOMOFFSET    = 1,
            EVENTBASED      = 2,
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
        System = {
            Regex = {},
            Linq = {Enumerable = {
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

local type_String = System.Type.GetType("System.String");
System.Regex = System.Type.GetType("System.Text.RegularExpressions.Regex, System.Text.RegularExpressions, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a");
CONST.Methods.System.Regex.Replace = function (string, pattern, replacement)
    return System.Regex:GetMethod(
        "Replace",
        CONST.Enums.BindingFlags.Convert(CONST.Enums.BindingFlags.Public | CONST.Enums.BindingFlags.Static),
        luanet.make_array(System.Type, {type_String, type_String, type_String})
    ):Invoke(nil, luanet.make_array(System.String, {string, pattern, replacement}));
end

local type_LocalText = luanet.ctype(RogueEssence.LocalText);
CONST.Methods.IsLocalText = function (object)
    if type(object) == 'userdata' then
        return type_LocalText:IsAssignableFrom(object:GetType());
    end
    return false;
end

return CONST;