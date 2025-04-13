local logger = require 'screenkeyboard.lib.logger' ('screenkeyboard','ScreenKeyboard');
local switch = require 'screenkeyboard.lib.switchcaser';
local tag = require 'screenkeyboard.lib.tag_reader';
local CONST = require 'screenkeyboard.lib.constants';
    local Dir8 = CONST.Enums.Dir8;
    local DirH = CONST.Enums.DirH;
    local __Object = luanet.import_type 'System.Object';

local type_TextInputMenu = luanet.ctype(RogueEssence.Menu.TextInputMenu);
local type_MenuText = luanet.ctype(RogueEssence.Menu.MenuText);
local array_NonPublic_Instance = LUA_ENGINE:LuaCast(36, CONST.Classes.System.BindingFlags);
local array_Object_Empty = luanet.make_array(__Object, {});
local __TextInputMenu_UpdatePickerPos = type_TextInputMenu:GetMethod("UpdatePickerPos", array_NonPublic_Instance);
local __TextInputMenu_ProcessTextInput = type_TextInputMenu:GetMethod("ProcessTextInput", array_NonPublic_Instance);

local KEYBOARD_LABEL = "MTK_KEYBOARD";
local defaultKeyboard = require 'screenkeyboard' .keyboards.alphanumeric;

---@type screenkeyboard.KeyboardStackEntry[]
local keyboardStack = {}

---@class screenkeyboard.KeyboardStackEntry
local keystackEntry = {
    ---@type unknown
    ref = nil,
    isCMenu = false,
    isScriptedMenu = false,
    ---@type unknown
    textEntryObject = nil,
    coordinates = {x=0,y=0},
    ---@type screenkeyboard.Keyboard[]
    customKeyboards = {},
    ---@type screenkeyboard.Keyboard
    currentKeyboard = defaultKeyboard,
    __keyboardScroll = 0
}
keystackEntry.__index = keystackEntry;

local keyboard = {
    ---@type any
    __menu = nil,
    rows = {},
    sidebar = {
        {
            isKeyboardSwitcher = true,
            label = "",
            action = nil
        },
        {
            isKeyboardSwitcher = true,
            label = "[^cyan][$screenkeyboard:keyboard/alphanumeric]",
            action = nil
        },
        {
            isKeyboardSwitcher = true,
            label = "[$screenkeyboard:keyboard/symbol]",
            action = nil
        },
        {
            isTypeMode = true,
            label = "[$screenkeyboard:type/over]",
            action = nil
        },
        {
            isDelete = true,
            label = "[$screenkeyboard:keyboard/delete]",
            ---@param entry screenkeyboard.KeyboardStackEntry
            action = function (entry, input)
                if entry.isCMenu then -- menu.entry_field:sub(1, utf8.offset(menu.entry_field, -1) - 1)
                    if #entry.ref.Text.Text > 0 then
                        entry.ref.Text:SetText(entry.ref.Text.Text:sub(1,utf8.offset(entry.ref.Text.Text, -1) - 1));
                        __TextInputMenu_UpdatePickerPos:Invoke(entry.ref, luanet.make_array(CONST.Classes.System.Object, {}));
                    end
                elseif entry.textEntryObject and #entry.textEntryObject.Text > 0 then
                    entry.textEntryObject:SetText(entry.textEntryObject.Text:sub(1,utf8.offset(entry.textEntryObject.Text, -1) - 1));
                end
                _GAME:SE("Menu/Cancel");
            end
        },
        {
            isConfirm = true,
            label = "[$screenkeyboard:keyboard/end]",
            ---@param entry screenkeyboard.KeyboardStackEntry
            action = function (entry, input)
                _MENU:RemoveMenu();
                if entry.isCMenu then
                    entry.ref:GetType():GetMethod("Confirmed", array_NonPublic_Instance):Invoke(entry.ref, array_Object_Empty);
                elseif entry.isScriptedMenu then
                    entry.ref:Update(input);
                end
            end
        }
    },
    clock = 0,
    repeating = false
}

local function getKeyboardLabel(keyboard, comparedKeyboard)
    if keyboard and keyboard.label then
        return tag.parse(comparedKeyboard == keyboard and keyboard.label.selected or keyboard.label.default);
    end
    return '';
end

---@param board screenkeyboard.Keyboard
local function setKeyboardDisplay(stackEntry, board)
    for y = 0, 5 do
        for x = 0, 14 do
            keyboard.rows[y][x]:SetText(board.grid[y][x].text);
        end
    end
    if stackEntry then
        stackEntry.currentKeyboard = board;
    end
    if stackEntry and #stackEntry.customKeyboards > 0 then
        local totalKeyboards = #stackEntry.customKeyboards;
        local index = stackEntry.__keyboardScroll - 1;
        keyboard.sidebar[1].object:SetText(getKeyboardLabel(stackEntry.customKeyboards[index%totalKeyboards + 1], board));
        keyboard.sidebar[2].object:SetText(getKeyboardLabel(stackEntry.customKeyboards[(index+1)%totalKeyboards + 1], board));
        keyboard.sidebar[3].object:SetText(getKeyboardLabel(stackEntry.customKeyboards[(index+2)%totalKeyboards + 1], board));
    elseif keyboard.sidebar[1].object ~= nil then
        keyboard.sidebar[1].object:SetText('');
        keyboard.sidebar[2].object:SetText('');
        keyboard.sidebar[3].object:SetText('');
    end
end

---@param keyboards screenkeyboard.Keyboard[]?
---@return screenkeyboard.KeyboardStackEntry
local function addToKeyboardStack(reference, keyboards)
    local isC = LUA_ENGINE:TypeOf(reference) and LUA_ENGINE:TypeOf(reference):IsSubclassOf(type_TextInputMenu);
    local entry = {
        ref = reference,
        isCMenu = isC,
        isScriptedMenu = not isC,
        textEntryObject = nil,
        coordinates = {x=0,y=0},
        customKeyboards = keyboards or {}
    }

    if entry.isScriptedMenu then
        local textIndex = reference:GetElementIndexByLabel("TEXT_ENTRY");
        if textIndex >= 0 and (
            reference.Elements[textIndex]:GetType() == type_MenuText or
            reference.Elements[textIndex]:GetType():IsSubclassOf(type_MenuText)
        ) then
            entry.textEntryObject = reference.Elements[textIndex];
        end
    else
        entry.textEntryObject = reference.Text;
    end

    setmetatable(entry, keystackEntry);
    keyboardStack[#keyboardStack+1] = entry;

    if reference.Bounds.Bottom > keyboard.__menu.Bounds.Top - 8 then
        reference.Bounds = RogueElements.Rect(
            reference.Bounds.X, 66 - math.ceil(reference.Bounds.Height / 2),
            reference.Bounds.Width, reference.Bounds.Height
        );
    end
    _MENU:AddMenu(keyboard.__menu, true);
    --entry.ref.Inactive = false;
    if entry.isCMenu then
        __TextInputMenu_UpdatePickerPos:Invoke(entry.ref, array_Object_Empty);
        --entry.ref:UpdatePickerPos();
    end

    if keyboards and #keyboards > 0 then
        setKeyboardDisplay(entry, keyboards[1]);
    else
        setKeyboardDisplay(entry, require 'screenkeyboard' .keyboards.alphanumeric);
    end

    return entry;
end

---@param menu any
---@return boolean isKeyboardable
local function detectForKeyboard(menu)
    if LUA_ENGINE:TypeOf(menu) and LUA_ENGINE:TypeOf(menu):IsSubclassOf(type_TextInputMenu) then
        return true;
    end
    
    local textIndex = menu:GetElementIndexByLabel("TEXT_ENTRY");
    if textIndex >= 0 then
        return true;
    end
    return false;
end

local function openKeyboard(interface)
    local isKeyboard = detectForKeyboard(interface);
    if not isKeyboard then return logger:err("Passed interface into openKeyboard is unable to have a keyboard attached.") end
    addToKeyboardStack(interface);
    return;
end

---@param entry screenkeyboard.KeyboardStackEntry
keyboard.sidebar[1].action = function (entry)
    if entry.customKeyboards[1] ~= nil then
        local index = entry.__keyboardScroll - 1;
        entry.currentKeyboard = entry.customKeyboards[index%#entry.customKeyboards+1];
        entry.__keyboardScroll = (index)%#entry.customKeyboards;
        setKeyboardDisplay(entry, entry.currentKeyboard);
    end
end
---@param entry screenkeyboard.KeyboardStackEntry
keyboard.sidebar[2].action = function (entry)
    if entry.customKeyboards[1] ~= nil then
        local index = entry.__keyboardScroll;
        entry.currentKeyboard = entry.customKeyboards[index%#entry.customKeyboards+1];
        --entry.__keyboardScroll = index - 1;
        setKeyboardDisplay(entry, entry.currentKeyboard);
    else
        setKeyboardDisplay(entry, require 'screenkeyboard' .keyboards.alphanumeric);
        keyboard.sidebar[2].object:SetText(tag.parse('[^cyan][$screenkeyboard:keyboard/alphanumeric]'));
        keyboard.sidebar[3].object:SetText(tag.parse('[$screenkeyboard:keyboard/symbol]'));
    end
end
---@param entry screenkeyboard.KeyboardStackEntry
keyboard.sidebar[3].action = function (entry)
    if entry.customKeyboards[1] ~= nil then
        local index = entry.__keyboardScroll + 1;
        entry.currentKeyboard = entry.customKeyboards[index%#entry.customKeyboards+1];
        entry.__keyboardScroll = (index)%#entry.customKeyboards;
        setKeyboardDisplay(entry, entry.currentKeyboard);
    else
        setKeyboardDisplay(entry, require 'screenkeyboard' .keyboards.symbols)
        keyboard.sidebar[2].object:SetText(tag.parse('[$screenkeyboard:keyboard/alphanumeric]'));
        keyboard.sidebar[3].object:SetText(tag.parse('[^cyan][$screenkeyboard:keyboard/symbol]'));
    end
end

local keyboardKey;

local inputSwitch = switch {
    ---@param stackEntry screenkeyboard.KeyboardStackEntry
    [Dir8.UP] = function (stackEntry)
        stackEntry.coordinates.y = stackEntry.coordinates.y - 1;
        if stackEntry.coordinates.y < 0 then stackEntry.coordinates.y = 5 end
        _GAME:SE("Menu/Speak");
        keyboard.cursor:ResetTimeOffset();
    end,
    ---@param stackEntry screenkeyboard.KeyboardStackEntry
    [Dir8.DOWN] = function (stackEntry)
        stackEntry.coordinates.y = (stackEntry.coordinates.y + 1)%6;
        _GAME:SE("Menu/Speak");
        keyboard.cursor:ResetTimeOffset();
    end,
    ---@param stackEntry screenkeyboard.KeyboardStackEntry
    [Dir8.LEFT] = function (stackEntry)
        stackEntry.coordinates.x = stackEntry.coordinates.x - 1;
        if stackEntry.coordinates.x < -1 then stackEntry.coordinates.x = 14 end
        _GAME:SE("Menu/Speak");
        keyboard.cursor:ResetTimeOffset();
    end,
    ---@param stackEntry screenkeyboard.KeyboardStackEntry
    [Dir8.RIGHT] = function (stackEntry)
        stackEntry.coordinates.x = (stackEntry.coordinates.x + 1)%15;
        _GAME:SE("Menu/Speak");
        keyboard.cursor:ResetTimeOffset();
    end,
    [CONST.Enums.Keys.Escape] = function ()
        _MENU:RemoveMenu();
        _MENU:RemoveMenu();
        keyboardStack[#keyboardStack] = nil;
    end,
    [CONST.Enums.Keys.Backspace] = keyboard.sidebar[5].action,
    [CONST.Enums.Keys.Space] = function (stackEntry)
        if stackEntry.isCMenu then
            __TextInputMenu_ProcessTextInput:Invoke(stackEntry.ref, luanet.make_array(__Object, {' '}));
        else
            stackEntry.textEntryObject:SetText(stackEntry.textEntryObject.Text .. ' ');
        end
    end,

    ---@param stackEntry screenkeyboard.KeyboardStackEntry
    [CONST.Enums.Buttons.LeftTrigger] = function (stackEntry)
        for _ = 1, math.min(stackEntry.coordinates.x, 5) do
            if stackEntry.coordinates.x <= 0 then break end
            stackEntry.coordinates.x = stackEntry.coordinates.x - 1;
        end
        _GAME:SE("Menu/Speak");
        keyboard.cursor:ResetTimeOffset();
    end,
    ---@param stackEntry screenkeyboard.KeyboardStackEntry
    [CONST.Enums.Buttons.RightTrigger] = function (stackEntry)
        for _ = 1, math.min(14 - stackEntry.coordinates.x, 5) do
            stackEntry.coordinates.x = stackEntry.coordinates.x + 1;
        end
        _GAME:SE("Menu/Speak");
        keyboard.cursor:ResetTimeOffset();
    end,

    ---@param stackEntry screenkeyboard.KeyboardStackEntry
    [RogueEssence.FrameInput.InputType.Confirm] = function (stackEntry, input)
        if stackEntry.coordinates.x > -1 then
            keyboardKey = stackEntry.currentKeyboard.grid[stackEntry.coordinates.y][stackEntry.coordinates.x];

            if not keyboardKey.enabled then _GAME:SE("Menu/Cancel"); return true; end
            if keyboardKey.replacement ~= nil then
                if stackEntry.isCMenu then
                    __TextInputMenu_ProcessTextInput:Invoke(stackEntry.ref, luanet.make_array(__Object, {keyboardKey.replacement}));
                else
                    stackEntry.textEntryObject:SetText(stackEntry.textEntryObject.Text .. keyboardKey.replacement);
                end
            else
                if stackEntry.isCMenu then
                    __TextInputMenu_ProcessTextInput:Invoke(stackEntry.ref, luanet.make_array(__Object, {keyboardKey.text}));
                else
                    stackEntry.textEntryObject:SetText(stackEntry.textEntryObject.Text .. keyboardKey.text);
                end
            end
            _GAME:SE("Menu/Confirm");
            return true;
        else
            if keyboard.sidebar[stackEntry.coordinates.y + 1] then
                keyboard.sidebar[stackEntry.coordinates.y + 1].action(stackEntry, input);
                return true;
            end
        end
    end
}

local topOfStack;
local keyboard_input = function (i)
    topOfStack = keyboardStack[#keyboardStack];

    if i:JustPressed(RogueEssence.FrameInput.InputType.Confirm) then
        if inputSwitch(RogueEssence.FrameInput.InputType.Confirm, topOfStack, i) then
            return;
        end
    end

    if i:BaseKeyPressed(CONST.Enums.Keys.Escape) then
        inputSwitch(CONST.Enums.Keys.Escape, topOfStack, i);
        return;
    end

    if i:BaseButtonPressed(CONST.Enums.Buttons.LeftTrigger) then
        inputSwitch(CONST.Enums.Buttons.LeftTrigger, topOfStack, i);
        return;
    elseif i:BaseButtonPressed(CONST.Enums.Buttons.RightTrigger) then
        inputSwitch(CONST.Enums.Buttons.RightTrigger, topOfStack, i);
        return;
    end

    if i:BaseKeyPressed(CONST.Enums.Keys.Space) or i:BaseButtonPressed(CONST.Enums.Buttons.FaceTop) then
        inputSwitch(CONST.Enums.Keys.Space, topOfStack, i);
        return;
    end

    if i:BaseKeyPressed(CONST.Enums.Keys.Backspace) or i:BaseButtonPressed(CONST.Enums.Buttons.FaceLeft) then
        inputSwitch(CONST.Enums.Keys.Backspace, topOfStack, i);
        return;
    end

    if i.Direction == i.PrevDirection then
        keyboard.clock = keyboard.clock + 1;
        if not keyboard.repeating then
            if keyboard.clock < 15 then
                return
            end
            keyboard.repeating = true;
        else
            if keyboard.clock < 4 then
                return
            end
            keyboard.clock = 0;
        end
    else
        keyboard.clock = 0;
        keyboard.repeating = false;
    end

    inputSwitch(i.Direction, topOfStack, i);

    if topOfStack.coordinates.x == -1 then
        keyboard.cursor.Loc = RogueElements.Loc(8, 10 + topOfStack.coordinates.y * 14);
    else
        keyboard.cursor.Loc = RogueElements.Loc(38 + 18 * topOfStack.coordinates.x, 10 + topOfStack.coordinates.y * 14);
    end
end

keyboard.__menu = RogueEssence.Menu.ScriptableMenu(KEYBOARD_LABEL, 0,132,320,100, keyboard_input);
keyboard.cursor = RogueEssence.Menu.MenuCursor(keyboard.__menu);
keyboard.__menu.Elements:Add(keyboard.cursor);

for y = 0, 5 do
    keyboard.rows[y] = {};
    for x = 0, 14 do
        keyboard.rows[y][x] = CONST.Functions.Menu.CreateText(utf8.char(x+y*16), x * 18 + 51, y * 14 + 10, DirH.NONE);
        keyboard.__menu.Elements:Add(keyboard.rows[y][x]);
    end
end
setKeyboardDisplay(nil, require 'screenkeyboard' .keyboards.alphanumeric);

for s, k in ipairs(keyboard.sidebar) do
    k.object = CONST.Functions.Menu.CreateText(tag.parse(k.label), 16, (s-1) * 14 + 10);
    keyboard.__menu.Elements:Add(k.object);
end

return {
    DetectKeyboardable = detectForKeyboard,
    AddToStack = addToKeyboardStack
}