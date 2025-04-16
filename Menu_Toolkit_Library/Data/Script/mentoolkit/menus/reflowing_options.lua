local CONST = require 'mentoolkit.lib.constants'
    local Dir8 = CONST.Enums.Dir8;
    local DirH = CONST.Enums.DirH;

---@class mentoolkit.Options
---@field onInput fun(menu: mentoolkit.Options,input: unknown): boolean Input Event. Return value cancels the default inputs (besides menu close).
local options_menu = {
    ---Handle with care!!<br>The RogueEssence Menu object.
    ---@type any
    __menu  = nil,
    ---Handle with care!!<br>The List of elements in the menu, automatically cleared by rebuilding.
    ---@type any
    __menuElements = nil,
    ---@type {[string]: any}
    __cache = {},
    ---Title of the window, placed at the top automatically
    ---@type string
    title   = nil,
    ---The currently selected option.
    currentSelection = 1,
    ---@type any
    cursor = nil,
    allowVerticalPageSwitch = true,
    options = {},
    ---Additional `IMenuElement`s to be added and kept when rebuilding the menu.
    elements = {}
}
options_menu.__index = options_menu

function options_menu:Rebuild()
    self.__menuElements:Clear();

    local mw = self.__menu.Bounds.Width;
    local mh = self.__menu.Bounds.Height;
    local y = 8;
    if self.title then
        self.__menuElements:Add(CONST.Functions.Menu.CreateText(self.title, 10, 8));
        self.__menuElements:Add(RogueEssence.Menu.MenuDivider(RogueElements.Loc(10,21), mw- 20));
        y = y + 15;
    end

    local pageCount = 0;

    local header = y;
    mh = math.floor((mh - header) / 13 - 1) * 13;
    header = header + 4;
    local currentPageOffset = self.__cache.page * mh; -- - header - 15
    y = -currentPageOffset;
    self.__cache.optionPositions = {}
    for i,k in pairs(self.options) do
        if k.labels then
            if y < mh and y >= 0 then
                if k.labels.left then
                    k.menuElements.left = CONST.Functions.Menu.CreateText(k.labels.left, k.x and 8 + k.x or 24, y + header);
                    self.__menuElements:Add(k.menuElements.left);
                end
                if k.labels.center then
                    k.menuElements.center = CONST.Functions.Menu.CreateText(k.labels.center, 8 + mw / 2, y + header, DirH.NONE)
                    self.__menuElements:Add(k.menuElements.center);
                end
                if k.labels.right then
                    k.menuElements.right = CONST.Functions.Menu.CreateText(k.labels.right, 8 + mw - 24, y + header, DirH.RIGHT)
                    self.__menuElements:Add(k.menuElements.right);
                end
            end
            self.__cache.optionPositions[i] = {10, y + header, page = math.floor((y + currentPageOffset) / (mh))};
            y = y + 13 * (k.lines or 1);
        elseif k.pagebreak then
            --if y <= mh - 18 and y > header then y = mh end
            y = math.ceil(y / mh) * mh;
        elseif k.height then
            if y >= 0 and y < mh then
                k.menuElements.divider = CONST.Methods.Menu.Elements.Divider(RogueElements.Loc(32, y + header), mw - 56);
                self.__menuElements:Add(k.menuElements.divider);
            end
            y = y + k.height;
        end
    end
    pageCount = math.max(pageCount, self.__cache.optionPositions[#self.options].page);

    if pageCount > 0 then
        self.__menuElements:Add(CONST.Functions.Menu.CreateText('('.. self.__cache.page + 1 ..'/'.. pageCount + 1 ..')', mw - 8, 8, DirH.RIGHT));
    end

    if #self.__cache.optionPositions > 0 then
        local currPos = self.__cache.optionPositions[self.currentSelection];
        if currPos then
            self.cursor.Loc = RogueElements.Loc(currPos[1],currPos[2]);
            self.__menuElements:Add(self.cursor);
        end
    end

    for _,k in pairs(self.elements) do
        self.__menuElements:Add(k);
    end
end

---@param rebuild boolean Should the menu rebuild before opening?
function options_menu:Open(rebuild)
    self.currentSelection = 1;
    self.__cache.page = 0;
    if self.options[self.currentSelection].selectable == false then
        repeat self.currentSelection = self.currentSelection + 1
        until self.options[self.currentSelection].selectable ~= false
    end

    if rebuild then self:Rebuild() end
    _MENU:AddMenu(self.__menu, true);
end

function options_menu:SetTitle(title)
    self.title = title;
    self:Rebuild();
end

---@param label string
---@param onSelected fun(self)
function options_menu:AddButton(label, onSelected)
    local option = {labels = {left = label}, onSelected = onSelected, enabled = true, menuElements = {}};
    option.lines = select(2, string.gsub(label, '\n', '\n')) + 1;
    table.insert(self.options, option);
    return option;
end
---@param label string
---@param onSelected fun()
function options_menu:AddSubmenuButton(label, onSelected)
    local option = {labels = {left = label,right='>'}, onSelected = onSelected, enabled = true, menuElements = {}};
    option.lines = select(2, string.gsub(label, '\n', '\n')) + 1;
    table.insert(self.options, option);
    return option;
end
function options_menu:AddText(text)
    local option = {labels = {left = text}, selectable = false, menuElements = {}};
    option.lines = select(2, string.gsub(text, '\n', '\n')) + 1;
    table.insert(self.options, option);
    return option;
end
function options_menu:AddHeader(text)
    local option = {labels = {left = text}, x = 8, selectable = false, menuElements = {}};
    option.lines = select(2, string.gsub(text, '\n', '\n')) + 1;
    table.insert(self.options, option);
    return option;
end
function options_menu:PageBreak()
    local option = {pagebreak = true, selectable = false, menuElements = {}};
    table.insert(self.options, option);
    return option;
end
function options_menu:AddSpacer(height)
    local option = {height = height, selectable = false, menuElements = {}};
    table.insert(self.options, option);
    return option;
end

---@param menu mentoolkit.Options
---@param input any
local controls_listener = function (menu, input)
    if input:JustPressed(RogueEssence.FrameInput.InputType.Cancel) or input:JustPressed(RogueEssence.FrameInput.InputType.Menu) then
        _GAME:SE("Menu/Cancel");
        _MENU:RemoveMenu();
        return;
    end

    if menu.onInput then if menu:onInput(input) then return end end

    if input:JustPressed(RogueEssence.FrameInput.InputType.Confirm) then
        if menu.options[menu.currentSelection] and menu.options[menu.currentSelection].enabled then
            _GAME:SE("Menu/Confirm");
            menu.options[menu.currentSelection].onSelected(menu.options[menu.currentSelection]);
        end
        return;
    end

    local cachedPositions = menu.__cache.optionPositions;
    local lastSelection = menu.currentSelection;

    if input.Direction == input.PrevDirection then return end
    if input.Direction == Dir8.UP then
        menu.currentSelection = menu.currentSelection - 1;
        if menu.currentSelection == 0 then menu.currentSelection = #menu.options end
        while menu.options[menu.currentSelection].selectable == false do
            menu.currentSelection = menu.currentSelection - 1;
            if menu.currentSelection == 0 then menu.currentSelection = #menu.options end
        end

        if cachedPositions[menu.currentSelection] then
            if not menu.allowVerticalPageSwitch and menu.__cache.page ~= cachedPositions[menu.currentSelection].page then
               menu.currentSelection = lastSelection;
               return;
            end
            menu.__cache.page = cachedPositions[menu.currentSelection].page;
        end
        _GAME:SE("Menu/Select");

        menu.cursor:ResetTimeOffset();
        menu:Rebuild();
        return;
    end
    if input.Direction == Dir8.DOWN then
        menu.currentSelection = menu.currentSelection % #menu.options + 1;
        while menu.options[menu.currentSelection].selectable == false do
            menu.currentSelection = menu.currentSelection % #menu.options + 1;
        end

        if cachedPositions[menu.currentSelection] then
            if not menu.allowVerticalPageSwitch and menu.__cache.page ~= cachedPositions[menu.currentSelection].page then
               menu.currentSelection = lastSelection;
               return;
            end
            menu.__cache.page = cachedPositions[menu.currentSelection].page;
        end
        _GAME:SE("Menu/Select");

        menu.cursor:ResetTimeOffset();
        menu:Rebuild();
        return;
    end
    if input.Direction == Dir8.LEFT then
        _GAME:SE("Menu/Skip");
        menu.__cache.page = menu.__cache.page - 1
        while (cachedPositions[menu.currentSelection] and cachedPositions[menu.currentSelection].page ~= menu.__cache.page)
        or menu.options[menu.currentSelection].selectable == false do
            menu.currentSelection = menu.currentSelection - 1;
            if menu.currentSelection == 0 then
                menu.currentSelection = #menu.options; menu.__cache.page = cachedPositions[menu.currentSelection].page; break;
            end
        end
        menu.cursor:ResetTimeOffset();

        if not menu.allowVerticalPageSwitch then
            if cachedPositions[menu.currentSelection - 1] and cachedPositions[menu.currentSelection - 1].page == menu.__cache.page then
                while (cachedPositions[menu.currentSelection - 1] and cachedPositions[menu.currentSelection - 1].page == menu.__cache.page) do
                    menu.currentSelection = menu.currentSelection - 1;
                end
                menu.currentSelection = menu.currentSelection + 1;
            end
        end

        menu:Rebuild();
        return;
    end
    if input.Direction == Dir8.RIGHT then
        _GAME:SE("Menu/Skip");
        menu.__cache.page = menu.__cache.page + 1;
        while (cachedPositions[menu.currentSelection] and cachedPositions[menu.currentSelection].page ~= menu.__cache.page)
        or menu.options[menu.currentSelection].selectable == false do
            menu.currentSelection = menu.currentSelection + 1;
            if menu.currentSelection >= #menu.options then
                menu.currentSelection = 1; menu.__cache.page = cachedPositions[menu.currentSelection].page; break;
            end
        end
        menu.cursor:ResetTimeOffset();

        menu:Rebuild();
        return;
    end
end

---@deprecated
---@return mentoolkit.Options
return function(x, y, w, h)
    local o = {
        options = {}, elements = {}, __cache = {page = 0, optionPositions = {}}
    };
    o.__menu = RogueEssence.Menu.ScriptableMenu(x,y,w,h, function(i) controls_listener(o, i) end);
    o.cursor = RogueEssence.Menu.MenuCursor(o.__menu);
    o.__menuElements = o.__menu.Elements;
    setmetatable(o, options_menu);
    return o
end