local CONST = require 'pmdorand.lib.constants'
    local Replace = CONST.Methods.System.Regex.Replace;
local data = require 'pmdorand.randomizer.data'
local switch = require 'mentoolkit.lib.switchcaser'

local configButtonGen = switch {
    ['subtable'] = function (page, label, id, configBuilderTable, playerConfigValue, playerConfigTable)
        return page:AddSubmenuButton(label, CONST.FUNCTION_EMPTY);
    end,
    ['toggle'] = function (page, label, id, configBuilderTable, playerConfigValue, playerConfigTable)
        return page:AddButton(label, function (self)
            playerConfigTable[id] = not playerConfigTable[id];
            self:SetLabel('right', data.language.toggle(playerConfigTable[id]))
        end):SetLabel('right', data.language.toggle(playerConfigValue));
    end,
    ['percent'] = function (page, label, id, configBuilderTable, playerConfigValue, playerConfigTable)
        return page:AddButton(label, CONST.FUNCTION_EMPTY):SetLabel('right', string.format('%.2f%%', playerConfigValue * 100));
    end
}

local options_menu = require 'mentoolkit.menus.paginated_options'
local items_menu, item_effects_list, item_effect_info;

---@param effect_name string
---@param configuration PMDOR.ConfigTemplate
local function openConfigMenu(effect_name, configuration)
    local menu = options_menu.create(40, 32, 268, 115);
    menu.title = "[^gray][$pmdorand:subtitle/itemeffects][color] > [$pmdorand:effect/item/".. effect_name .."]"
    menu:AddDescriptionPanel(0,172,320,68);

    local button = 4;
    local page = menu:AddPage();
    local userConfig = data.options.items.effects[effect_name];

    page:AddButton("Randomization", function (self)
        userConfig.enabled = not userConfig.enabled;
        self:SetLabel('right', data.language.toggle(userConfig.enabled));
        page:Refresh();
    end):SetLabel('right', data.language.toggle(userConfig.enabled))
        :SetDescription(data.language.descriptionText "mentoolkit:description/randomize/itemeffect");

    page:AddSubmenuButton("Appearance Settings", CONST.FUNCTION_EMPTY)
        :SetDescription(data.language.descriptionText "mentoolkit:description/itemeffect/appearance");
    page:AddButton("Modify Chance", CONST.FUNCTION_EMPTY):SetLabel('right', string.format('%.2f%%', userConfig.modifyRate * 100))
        :SetDescription(data.language.descriptionText "mentoolkit:description/itemeffect/modify");
    page:AddButton("Disappearance Chance", CONST.FUNCTION_EMPTY):SetLabel('right', string.format('%.2f%%', userConfig.disappearanceChance * 100))
        :SetDescription(data.language.descriptionText "mentoolkit:description/itemeffect/disappear");

    page:AddSpacer(5);

    for _,k in ipairs(configuration) do
        if button > 5 then page = menu:AddPage(); button = 0; end
        local i = k.id;

        local label;

        if RogueEssence.Text.Strings:ContainsKey(string.format("pmdorand:config/effect/item/%s/%s.label", effect_name, i)) then
            label = string.format("[$pmdorand:config/effect/item/%s/%s.label]", effect_name, i)
        else
            label = Replace(Replace(i, '(?<=[A-Z])(?=[A-Z][a-z])',' '), '(?<=[a-z])(?=[A-Z])',' ');
            label = label:sub(1,1):upper() .. label:sub(2);
        end

        local ret = configButtonGen(k.type, page, label, i, k, userConfig.settings[i], userConfig.settings);
        if ret then
            if RogueEssence.Text.Strings:ContainsKey(string.format("pmdorand:config/effect/item/%s/%s.title", effect_name, i)) then
                ret:SetDescription(data.language.descriptionText(string.format("pmdorand:config/effect/item/%s/%s", effect_name, i)));
            else
                ret:SetDescription('','');
            end
            button = button + 1;
        end
    end

    menu:Open(true);
    return menu;
end

local function openConfigList()
    if item_effects_list and not data.knownDirtiedMenus.itemEffects then return item_effects_list:Open(true); end
    local menu = options_menu.create(32,32,220,115);
    menu.title = "[^gray][$pmdorand:title/items][color] > [$pmdorand:subtitle/itemeffects]";
    menu:AddDescriptionPanel(0,185,320,55);

    local entries = {};
    for id, k in pairs(data.external.items.itemEffects) do
        entries[#entries+1] = {value = id, sortNum = k.sortPriority, sortStr = string.lower(id)};
    end
    table.sort(entries, function (a, b)
        if a.sortNum ~= nil and b.sortNum ~= nil then
            if a.sortNum == b.sortNum then
                return a.sortStr < b.sortStr;
            else
                return a.sortNum < b.sortNum;
            end
        elseif a.sortNum ~= nil then
            return true;
        elseif b.sortNum ~= nil then
            return false;
        else
            return a.sortStr < b.sortStr;
        end
    end);

    local page = menu:AddPage();

    page:AddButton("Randomization", function (self)
        data.options.items.effects.enabled = not data.options.items.effects.enabled;
        self:SetLabel('right', data.language.toggle(data.options.items.effects.enabled));
        page:Refresh();
    end):SetLabel('right', data.language.toggle(data.options.items.effects.enabled))
        :SetDescription(data.language.descriptionText "mentoolkit:description/randomize/itemeffects");

    page:AddSpacer(5);

    local buttons = 1;
    local hasTLName, hasTLDesc;
    for _,ido in ipairs(entries) do
        local id = ido.value;
        local k = data.external.items.itemEffects[id];
        if buttons > 5 then page = menu:AddPage(); buttons = 0; end

        local button = page:AddButton((data.options.items.effects.enabled and '' or '[^gray]')..string.format('[$pmdorand:effect/item/%s]', id), function ()
            openConfigMenu(id, data.external.configs.itemEffects[id]):SetCallback('onClose', function ()
                menu.pages[menu.currentPage]:Refresh();
            end);
        end)
            :SetCallback('onRefresh', function (self)
                self:SetLabel('left', (data.options.items.effects.enabled and '' or '[^gray]')..string.format('[$pmdorand:effect/item/%s]', id));
                self:SetLabel('right', data.language.toggle(k.options.enabled, data.options.items.effects.enabled) ..'[color] >');
            end);

        hasTLName = RogueEssence.Text.Strings:ContainsKey(string.format("pmdorand:effect/item/%s.name", id));
        hasTLDesc = RogueEssence.Text.Strings:ContainsKey(string.format("pmdorand:effect/item/%s.description", id));
        button:SetDescription(
            hasTLName and string.format('[$pmdorand:effect/item/%s.name]', id) or string.format('[$pmdorand:effect/item/%s]', id),
            hasTLDesc and string.format('[$pmdorand:effect/item/%s.description]', id) or ''
        );
        buttons = buttons + 1;
    end

    item_effects_list = menu;
    data.knownDirtiedMenus.itemEffects = false;
    menu:Open(true);
end

return function()
    if items_menu == nil then
        items_menu = options_menu.create(16,40,220,89);
        items_menu.title = "[$pmdorand:title/items]"

        local page = items_menu:AddPage();
        page:AddButton("Randomization", function (self)
            data.options.items.enabled = not data.options.items.enabled;
            self:SetLabel('right', data.language.toggle(data.options.items.enabled));
        end):SetLabel('right', data.language.toggle(data.options.items.enabled));
        page:AddSubmenuButton("Sprites", CONST.FUNCTION_EMPTY);
        page:AddSubmenuButton("Prices & Stacks", CONST.FUNCTION_EMPTY);
        page:AddSubmenuButton("Item Effects", function ()
            openConfigList();
        end);
    end
    items_menu:Open(true);
end