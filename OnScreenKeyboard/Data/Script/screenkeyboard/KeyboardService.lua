---@diagnostic disable: undefined-global
require 'origin.common'
require 'origin.services.baseservice'

--local CONST = require 'mentoolkit.lib.constants'

local __Environment = luanet.import_type('System.Environment');
local __BindingFlags = luanet.import_type('System.Reflection.BindingFlags');
--                                                                               36 = NonPublic | Instance
local __MenuManager_menus = _MENU:GetType():GetField("menus", LUA_ENGINE:LuaCast(36, __BindingFlags));

local logger = require 'screenkeyboard.lib.logger' ('screenkeyboard','ScreenKeyboard')
local keyboard = require 'screenkeyboard.lib.ui_keyboard'
local waitingForMenus = {}

local OSKS = Class('KeyboardService', BaseService)
local OSKS_Shared = {
    Callbacks = {
        onAddMenu           = nil
    }
}
local menuClasses = {
    BaseTextInput = luanet.ctype(RogueEssence.Menu.TextInputMenu)
}

OSKS.initialize = function(self)
    BaseService.initialize(self);
    logger:debug("class init");
end

---Called whenever a menu is shown
---@param _ string 
---@param args any
OSKS_Shared.Callbacks.onAddMenu = function (_, args)
    local menu = args[0];

    if keyboard.DetectKeyboardable(menu) then
        waitingForMenus[#waitingForMenus+1] = {
            menu = menu,
            requestAt = __Environment.TickCount64
        };
    end
end

OSKS.Subscribe = function(_, med)
    med:Subscribe("KeyboardService", EngineServiceEvents.AddMenu, OSKS_Shared.Callbacks.onAddMenu);

    local menuList;
    med:Subscribe("KeyboardService", EngineServiceEvents.Update, function(gameTime)
        if waitingForMenus[1] ~= nil then
            menuList = __MenuManager_menus:GetValue(_MENU);
            if menuList ~= nil and menuList.Count > 0 and menuList[menuList.Count - 1] == waitingForMenus[1].menu then
                keyboard.AddToStack(waitingForMenus[1].menu, {
                    require 'screenkeyboard' .keyboards.alphanumeric,
                    require 'screenkeyboard' .keyboards.symbols,
                    require 'screenkeyboard' .keyboards.keycaps
                });
                table.remove(waitingForMenus, 1);
            elseif __Environment.TickCount64 - waitingForMenus[1].requestAt > 4000 then
                logger:warn("menu wait expired")
                table.remove(waitingForMenus, 1);
            end
        else
            menuList = __MenuManager_menus:GetValue(_MENU);
            if menuList.Count == 0 then return end
            keyboard.QueryClosure(menuList[menuList.Count - 1]);
        end
    end);
end

SCRIPT:AddService("KeyboardService", OSKS:new())
return OSKS