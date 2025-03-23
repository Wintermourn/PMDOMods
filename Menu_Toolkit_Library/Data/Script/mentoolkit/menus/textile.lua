local CONST = require 'mentoolkit.lib.constants'
    local Dir8 = CONST.Enums.Dir8;
    local DirH = CONST.Enums.DirH;
    local DirV = CONST.Enums.DirV;

---@class mentoolkit.Textile
---Menu type for text and visuals- no checks for buttons, only pages of text.
local textile_menu = {
    ---Handle with care!!<br>The RogueEssence Menu object.
    ---@type any
    __menu  = nil,
    ---Handle with care!!<br>The List of elements in the menu, automatically cleared by rebuilding.
    ---@type any
    __menuElements = nil,
    ---@type {[string]: any}
    __cache = {tick = 0},
    ---Title of the window, placed at the top automatically
    ---@type string
    title   = nil,
    scroll = 0,
    canScrollMore = false,
    currentPage = 1,
    ---@type mentoolkit.Textile.Page
    pages = {},
    ---Additional `IMenuElement`s to be added and kept when rebuilding the menu.
    global_elements = {}
}
textile_menu.__index = textile_menu;

---@class mentoolkit.Textile.Page
local textile_page = {
    ---@type mentoolkit.Textile
    __owner = nil,
    ---@type string[]
    flowed_contents = {},
    ---Additional `IMenuElement`s to be added and kept when rebuilding the menu on this page.
    elements = {}
}
textile_page.__index = textile_page;

function textile_menu:Rebuild()
    self.__menuElements:Clear();

    local head = 0;
    local my = 8;
    local mw = self.__menu.Bounds.Width;
    local mh = self.__menu.Bounds.Height;

    if self.title then
        self.__menuElements:Add(CONST.Functions.Menu.CreateText(self.title, 10, 8));
        self.__menuElements:Add(CONST.Functions.Menu.CreateText("Page ".. self.currentPage ..' / '.. #self.pages, mw - 10, 8, DirH.RIGHT));
        self.__menuElements:Add(CONST.Methods.Menu.Elements.Divider(RogueElements.Loc(10,21), mw- 20));

        mh = mh - 27;
        my = my + 17;
    end
    mh = mh - 16;

    for _,k in pairs(self.global_elements) do
        self.__menuElements:Add(k);
    end

    if self.pages[self.currentPage] == nil then
        self.__menuElements:Add(CONST.Functions.Menu.CreateText("[color=#999999]This page doesn't exist.[color]", mw/2, my +mh/2, DirH.NONE, DirV.NONE));
    else
        ---@type mentoolkit.Textile.Page
        local thisPage = self.pages[self.currentPage];

        local y;
        self.canScrollMore = false;
        for i,k in pairs(thisPage.flowed_contents) do
            y = (i - self.scroll - 1);
            if y > mh/13 and not k:match("^%s*$") then self.canScrollMore = true break end
            if y >= 0 then
                self.__menuElements:Add(CONST.Functions.Menu.CreateText(k, 12, y * 13 + my));
            end
        end

        if self.canScrollMore then
            self.__menuElements:Add(CONST.Functions.Menu.CreateText('...', mw/2, self.__menu.Bounds.Height - 16, DirH.NONE));
        end

        for _,k in pairs(thisPage.elements) do
            self.__menuElements:Add(k);
        end
    end
end

---@param rebuild boolean Should the menu rebuild before opening?
function textile_menu:Open(rebuild)
    if rebuild then self:Rebuild() end
    _MENU:AddMenu(self.__menu, true);
end

---@param page integer
---@param rebuild boolean Should the menu rebuild before opening?
function textile_menu:OpenToPage(page, rebuild)
    self.currentPage = page;
    if rebuild then self:Rebuild() end
    _MENU:AddMenu(self.__menu, true);
end

function textile_menu:SetTitle(title)
    self.title = title;
    self:Rebuild();
end

---@return mentoolkit.Textile.Page
function textile_menu:CreatePage()
    local o = {
        __owner = self,
        flowed_contents = {}, elements = {}
    };
    setmetatable(o, textile_page);
    table.insert(self.pages, o);
    return o;
end

--#region Textile Page Methods

local function split(inputstr, sep)
    local t = {};
    for str in string.gmatch(inputstr, "([^"..sep.."]*)") do
      table.insert(t, str);
    end
    return t;
end

---@param x integer
---@param y integer
---@param text string
---@param dirx RogueElements.DirH?
---@param diry RogueElements.DirV?
function textile_page:TextAt(x,y, text, dirx, diry)
    table.insert(self.elements, CONST.Functions.Menu.CreateText(text, x, y, dirx, diry));
end

function textile_page:Insert(index, text)
    local lines = RogueEssence.Menu.MenuText.BreakIntoLines(text, self.__owner.__menu.Bounds.Width - 16);

    for i = 0, lines.Length - 1 do
        table.insert(self.flowed_contents, index + i, lines[i]);
    end
end

function textile_page:Append(text)
    local lines = RogueEssence.Menu.MenuText.BreakIntoLines(text, self.__owner.__menu.Bounds.Width - 16);

    for i = 0, lines.Length - 1 do
        self.flowed_contents[#self.flowed_contents+1] = lines[i];
    end
end

--#endregion

---@param menu mentoolkit.Textile
---@param input any
local controls_listener = function (menu, input)
    if input:JustPressed(RogueEssence.FrameInput.InputType.Cancel) or input:JustPressed(RogueEssence.FrameInput.InputType.Menu) then
        _GAME:SE("Menu/Cancel");
        _MENU:RemoveMenu();
        return;
    end
    if #menu.pages == 0 then return end

    if input.Direction == Dir8.UP then
        if menu.__cache.tick == 0 and menu.scroll > 0 then
            menu.__cache.tick = 9;
            _GAME:SE("Menu/Speak");
            menu.scroll = menu.scroll - 1;
        end
        menu.__cache.tick = menu.__cache.tick - 1;

        menu:Rebuild();
        return;
    end
    if input.Direction == Dir8.DOWN then
        if menu.__cache.tick == 0 and menu.canScrollMore then
            menu.__cache.tick = 9;
            _GAME:SE("Menu/Speak");
            menu.scroll = menu.scroll + 1;
        end
        menu.__cache.tick = menu.__cache.tick - 1;

        menu:Rebuild();
        return;
    end
    if input.Direction == input.PrevDirection then menu.__cache.tick = 0; return; end
    if input.Direction == Dir8.NONE then
        menu.__cache.tick = 0;
        return;
    end
    if input.Direction == Dir8.LEFT then
        _GAME:SE("Menu/Skip");
        menu.currentPage = menu.currentPage - 1;
        if menu.currentPage == 0 then menu.currentPage = #menu.pages; end
        menu.scroll = 0;

        menu:Rebuild();
        return;
    end
    if input.Direction == Dir8.RIGHT then
        _GAME:SE("Menu/Skip");
        menu.currentPage = menu.currentPage % #menu.pages + 1;
        menu.scroll = 0;

        menu:Rebuild();
        return;
    end
end

---@return mentoolkit.Textile
return function(x, y, w, h)
    local o = {
        pages = {}, global_elements = {}, currentPage = 1, __cache = {tick = 0}, scroll = 0, title = nil
    };
    o.__menu = RogueEssence.Menu.ScriptableMenu(x,y,w,h, function(i) controls_listener(o, i) end);
    o.__menuElements = o.__menu.MenuElements;
    setmetatable(o, textile_menu);
    return o
end