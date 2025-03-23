---@diagnostic disable: undefined-global
require 'origin.common'
require 'origin.services.baseservice'
local randomizer = require 'wintermourn_pmdorand.randomizer'

local logger = require 'mentoolkit.lib.logger' ('wintermourn.pmdorand', 'PMDORAND')
local data = require 'wintermourn_pmdorand.randomizer.data';

local TMS = Class('TopMenuService', BaseService)
local TMS_Shared = {
    Callbacks = {
        onAddMenu       = nil,
        onTopMenuAdded  = nil
    }
}

TMS.initialize = function(self)
    BaseService.initialize(self);
    logger:debug("class init");
end

---Called whenever a menu is shown
---@param _ string 
---@param args any
TMS_Shared.Callbacks.onAddMenu = function (_, args)
    local menu = args[0];

    local className = menu:GetType().Name;
    if tostring(className) == "TopMenu" then TMS_Shared.Callbacks.onTopMenuAdded(menu) end
end

---Called when the Top Menu is opened
---@param topMenu any (Top Menu C# Object)
TMS_Shared.Callbacks.onTopMenuAdded = function (topMenu)
    topMenu.Choices:Insert(
        1,
        RogueEssence.Menu.MenuTextChoice(
            'MENU_RANDOMIZER',
            STRINGS:FormatKey("pmdorand:topmenu"),
            randomizer.OpenMenu
        )
    );
    topMenu:ImportChoices(topMenu.Choices);
    --[[ RogueEssence.Menu.VertChoiceMenu.Initialize(
        topMenu,
        RogueElements.Loc(16,16),
        RogueEssence.Menu.SingleStripMenu.CalculateChoiceLength(topMenu, topMenu.Choices, 72),
        topMenu.Choices.ToArray(),
        0); ]]
end

TMS.Subscribe = function(_, med)
    med:Subscribe("TopMenuService", EngineServiceEvents.AddMenu, TMS_Shared.Callbacks.onAddMenu);
    med:Subscribe("TopMenuService", EngineServiceEvents.Update, function(gameTime)
        if data.updateCoroutine ~= nil then
            local output, error = coroutine.resume(data.updateCoroutine);
            if not output and error then
                logger:err(error);
            end
            if coroutine.status(data.updateCoroutine) == 'dead' then data.updateCoroutine = nil end
        end
    end);
end

SCRIPT:AddService("TopMenuService", TMS:new())
return TMS