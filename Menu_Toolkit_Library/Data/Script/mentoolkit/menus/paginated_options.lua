local CONST = require 'mentoolkit.lib.constants'
    local Dir8 = CONST.Enums.Dir8;
    local DirH = CONST.Enums.DirH;

---@class mentoolkit.PaginatedOptions
---@field onInput fun(menu: mentoolkit.PaginatedOptions,input: unknown): boolean Input Event. Return value cancels the default inputs (besides menu close).
local paginated_options_menu = {
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
    currentPage = 1,
    ---The currently selected option.
    currentSelection = 1,
    ---@type any
    cursor = nil,
    ---@type mentoolkit.PaginatedOptions.Page[]
    pages = {},
    ---Additional `IMenuElement`s to be added and kept when rebuilding the menu.
    elements = {},
    __description = {
        menu = nil, title = '', description = ''
    }
}
paginated_options_menu.__index = paginated_options_menu;

---@class mentoolkit.PaginatedOptions.Page
local options_page = {
    ---@type mentoolkit.PaginatedOptions
    __owner = nil,
    contents = {},
    additionalElements = {}
}
options_page.__index = options_page;

---@class mentoolkit.PaginatedOptions.Labelled
local labelled = {
    ---@type mentoolkit.PaginatedOptions.Page
    __owner = nil,
    __menuElements = {},
    enabled = true,
    visible = true,
    selectable = true,
    cursorAnchor = RogueElements.Loc(0,0),
    --- How many pixels away from the window's left that the object should be able to reach.
    left = 16,
    ---Do not modify directly.<br>Use `labelled:SetLabel(direction, text)` instead.
    labels = {},
    actions = {
        ---@type fun(self: mentoolkit.PaginatedOptions.Labelled)
        onSelected = nil,
        ---@type fun(self: mentoolkit.PaginatedOptions.Labelled, direction: -1|1, shiftHeld: boolean)
        onSlide = nil
    }
}
labelled.__index = labelled;

function paginated_options_menu:Rebuild ()
    self.__menuElements:Clear();

    local mw = self.__menu.Bounds.Width;
    local mh = self.__menu.Bounds.Height;
    local y = 0;
    if self.title then
        if not self.__cache.hasTitle then
            self.__cache.hasTitle = true;
            self.__cache.globalElements.title = CONST.Functions.Menu.CreateText(self.title, 10, 8);
            self.__cache.globalElements.divider = RogueEssence.Menu.MenuDivider(RogueElements.Loc(10,21), mw- 20);
        end
        self.__menuElements:Add(self.__cache.globalElements.title);
        self.__menuElements:Add(self.__cache.globalElements.divider);

        y = y + 26;
    end

    if self.pages[self.currentPage] then
        for _,k in pairs(self.pages[self.currentPage].contents) do
            if not k.visible then goto skip_element; end
            k.cursorAnchor = RogueElements.Loc(8, y);
            if k.__menuElements.label_left then
                k.__menuElements.label_left.Loc = RogueElements.Loc(k.__menuElements.label_left.Loc.X, y);
                self.__menuElements:Add(k.__menuElements.label_left);
            end
            if k.__menuElements.label_center then
                k.__menuElements.label_center.Loc = RogueElements.Loc(k.__menuElements.label_center.Loc.X, y);
                self.__menuElements:Add(k.__menuElements.label_center);
            end
            if k.__menuElements.label_right then
                k.__menuElements.label_right.Loc = RogueElements.Loc(k.__menuElements.label_right.Loc.X, y);
                self.__menuElements:Add(k.__menuElements.label_right);
            end
            y = y + (k.textHeight or 0);
            if k.__menuElements.divider then
                k.__menuElements.label_left.Loc = RogueElements.Loc(k.__menuElements.divider.Loc.X, y);
                self.__menuElements:Add(k.__menuElements.divider);
                y = y + k.dividerHeight;
            end
            ::skip_element::
        end
    end

    self.cursor.Loc = RogueElements.Loc(8,26);
    self.__menuElements:Add(self.cursor);

    for i,k in pairs(self.elements) do
        self.__menuElements:Add(k);
    end
end

function paginated_options_menu:Open (rebuild)
    self.currentSelection = 1;
    if self.__description.menu and self.pages[self.currentPage] then
        self.pages[self.currentPage]:Refresh();
        local entry = self.pages[self.currentPage].contents[self.currentSelection];
        if entry and entry.description then
            self:SetDescription(entry.description.title, entry.description.content);
        end
    end
    if rebuild then self:Rebuild() end

    if self.__description.menu then
        _MENU:AddMenu(self.__description.menu, true);
    end
    _MENU:AddMenu(self.__menu, true);
end

function paginated_options_menu:AddDescriptionPanel(x,y,w,h)
    if self.__description.menu then return self.__description.menu; end
    self.__description.menu = RogueEssence.Menu.ScriptableMenu(x,y,w,h, function(i)
        if i:JustPressed(RogueEssence.FrameInput.InputType.Cancel) or i:JustPressed(RogueEssence.FrameInput.InputType.Menu) then
            _GAME:SE("Menu/Cancel");
            _MENU:RemoveMenu();
            return;
        end
    end);
    self.__description.titleObject = CONST.Functions.Menu.CreateText('', 10, 8);
    self.__description.descriptionObject = RogueEssence.Menu.DialogueText('', RogueElements.Rect(10, 25,w-16,h-33), 13);
---@diagnostic disable-next-line: undefined-field
    local entries = self.__description.menu.MenuElements;
    entries:Add(self.__description.titleObject);
    entries:Add(RogueEssence.Menu.MenuDivider(RogueElements.Loc(10,21), w - 20));
    entries:Add(self.__description.descriptionObject);
end

function paginated_options_menu:SetDescription(title, description)
    if not self.__description.menu then return end
    self.__description.titleObject:SetText(title);
    self.__description.descriptionObject:SetAndFormatText(description);
end

---@return mentoolkit.PaginatedOptions.Page
function paginated_options_menu:AddPage ()
    local page = {
        __owner = self,
        contents = {},
        additionalElements = {}
    }
    setmetatable(page, options_page);
    self.pages[#self.pages+1] = page;
    return page;
end

---@param label string
---@return mentoolkit.PaginatedOptions.Labelled
function options_page:AddHeader(label)
    local option = {
        __owner = self,
        labels = {},
        enabled = false,
        selectable = false,
        actions = {},
        left = 12,
        __menuElements = {}
    };
    option.lines = select(2, string.gsub(label, '\n', '\n')) + 1;
    setmetatable(option, labelled);
    option:SetLabel('left', label);
    option:CalculateHeight();
    self.contents[#self.contents+1] = option;
    return option;
end

---@param label string
---@param onSelected fun(self: mentoolkit.PaginatedOptions.Labelled)
---@return mentoolkit.PaginatedOptions.Labelled
function options_page:AddButton(label, onSelected)
    local option = {
        __owner = self,
        labels = {},
        enabled = true,
        actions = {
            onSelected = onSelected
        },
        left = 16,
        __menuElements = {}
    };
    option.lines = select(2, string.gsub(label, '\n', '\n')) + 1;
    setmetatable(option, labelled);
    option:SetLabel('left', label);
    option:CalculateHeight();
    self.contents[#self.contents+1] = option;
    return option;
end

function options_page:Refresh()
    for _,k in pairs(self.contents) do
        if k.actions and k.actions.onRefresh then
            k.actions.onRefresh(k);
        end
    end
end

---@param label 'left'|'center'|'right'
---@param text string
---@return mentoolkit.PaginatedOptions.Labelled
function labelled:SetLabel(label, text)
    if label == 'left' then
        if self.__menuElements.label_left then
            self.__menuElements.label_left:SetText(text);
        else
            self.__menuElements.label_left = CONST.Functions.Menu.CreateText(text, self.left, 0);
        end
        self.labels.left = text;
    elseif label == 'center' then
        if self.__menuElements.label_center then
            self.__menuElements.label_center:SetText(text);
        else
            self.__menuElements.label_center = CONST.Functions.Menu.CreateText(text, self.__owner.__owner.__menu.Bounds.Width / 2, 0, DirH.NONE);
        end
        self.labels.center = text;
    elseif label == 'right' then
        if self.__menuElements.label_right then
            self.__menuElements.label_right:SetText(text);
        else
            self.__menuElements.label_right = CONST.Functions.Menu.CreateText(text, self.__owner.__owner.__menu.Bounds.Width - 12, 0, DirH.RIGHT);
        end
        self.labels.right = text;
    end
    return self;
end

function labelled:SetDescription(title, content)
    self.description = {title = title, content = content};
    return self;
end

---@overload fun(self: mentoolkit.PaginatedOptions.Labelled, eventname: 'onSelected', callback: fun(self: mentoolkit.PaginatedOptions.Labelled)): mentoolkit.PaginatedOptions.Labelled
---@overload fun(self: mentoolkit.PaginatedOptions.Labelled, eventname: 'onRefresh', callback: fun(self: mentoolkit.PaginatedOptions.Labelled)): mentoolkit.PaginatedOptions.Labelled
function labelled:SetCallback(eventname, callback)
    self.actions[eventname] = callback;
    return self;
end

function labelled:CalculateHeight()
    local maxHeight = 0;
    if self.labels.left then
        maxHeight = math.max(maxHeight, select(2, string.gsub(self.labels.left, '\n', '\n')) + 1);
    end
    if self.labels.center then
        maxHeight = math.max(maxHeight, select(2, string.gsub(self.labels.center, '\n', '\n')) + 1);
    end
    if self.labels.right then
        maxHeight = math.max(maxHeight, select(2, string.gsub(self.labels.right, '\n', '\n')) + 1);
    end
    self.textHeight = maxHeight * 13;

    self.height = maxHeight * 13;
    return self;
end

---comment
---@param menu mentoolkit.PaginatedOptions
---@param input any
---@return function|nil
local controls_listener = function (menu, input)
    if input:JustPressed(RogueEssence.FrameInput.InputType.Cancel) or input:JustPressed(RogueEssence.FrameInput.InputType.Menu) then
        _GAME:SE("Menu/Cancel");
        if menu.__description.menu then
            _MENU:RemoveMenu();
        end
        _MENU:RemoveMenu();
        return;
    end

    if menu.onInput then if menu:onInput(input) then return end end

    if menu.pages[menu.currentPage] then
        local options = menu.pages[menu.currentPage].contents;
    
        if input:JustPressed(RogueEssence.FrameInput.InputType.Confirm) then
            if options[menu.currentSelection] and options[menu.currentSelection].enabled then
                _GAME:SE("Menu/Confirm");
                options[menu.currentSelection].actions.onSelected(options[menu.currentSelection]);
            end
            return;
        end

        if input.Direction == input.PrevDirection then return end
        if input.Direction == Dir8.UP then
            menu.currentSelection = menu.currentSelection - 1;
            if menu.currentSelection == 0 then menu.currentSelection = #options end
            while not options[menu.currentSelection].visible or not options[menu.currentSelection].selectable do
                menu.currentSelection = menu.currentSelection - 1;
                if menu.currentSelection == 0 then menu.currentSelection = #options end
            end
            _GAME:SE("Menu/Select");

            if options[menu.currentSelection].description then
                menu:SetDescription(options[menu.currentSelection].description.title, options[menu.currentSelection].description.content);
            end
            menu.cursor.Loc = (options[menu.currentSelection].cursorAnchor or menu.cursor.Loc);
            menu.cursor:ResetTimeOffset();
        elseif input.Direction == Dir8.DOWN then
            menu.currentSelection = menu.currentSelection % #options + 1;
            if menu.currentSelection == 0 then menu.currentSelection = #options end
            while not options[menu.currentSelection].visible or not options[menu.currentSelection].selectable do
                menu.currentSelection = menu.currentSelection % #options + 1;
            end
            _GAME:SE("Menu/Select");

            if options[menu.currentSelection].description then
                menu:SetDescription(options[menu.currentSelection].description.title, options[menu.currentSelection].description.content);
            end
            menu.cursor.Loc = (options[menu.currentSelection].cursorAnchor or menu.cursor.Loc);
            menu.cursor:ResetTimeOffset();
        elseif input.Direction == Dir8.LEFT then
            menu.currentPage = menu.currentPage - 1;
            if menu.currentPage <= 0 then menu.currentPage = #menu.pages end
            options = menu.pages[menu.currentPage].contents;
            menu.currentSelection = 1;
            while not options[menu.currentSelection].visible or not options[menu.currentSelection].selectable do
                menu.currentSelection = menu.currentSelection % #options + 1;
            end
            _GAME:SE("Menu/Select");

            menu.cursor.Loc = (options[menu.currentSelection].cursorAnchor or menu.cursor.Loc);
            menu.cursor:ResetTimeOffset();

            menu.pages[menu.currentPage]:Refresh();
            menu:Rebuild();
        elseif input.Direction == Dir8.RIGHT then
            menu.currentPage = menu.currentPage % #menu.pages + 1;
            options = menu.pages[menu.currentPage].contents;
            menu.currentSelection = 1;
            while not options[menu.currentSelection].visible or not options[menu.currentSelection].selectable do
                menu.currentSelection = menu.currentSelection % #options + 1;
            end
            _GAME:SE("Menu/Select");

            menu.cursor.Loc = (options[menu.currentSelection].cursorAnchor or menu.cursor.Loc);
            menu.cursor:ResetTimeOffset();

            menu.pages[menu.currentPage]:Refresh();
            menu:Rebuild();
        end
    end
end

---@return mentoolkit.PaginatedOptions
return function(x, y, w, h)
    local o = {
        pages = {}, elements = {}, __cache = {hasTitle = false, globalElements = {}}, __description = {menu = nil, title = '', content = ''}
    };
    o.__menu = RogueEssence.Menu.ScriptableMenu(x,y,w,h, function(i) controls_listener(o, i) end);
    o.cursor = RogueEssence.Menu.MenuCursor(o.__menu);
    o.__menuElements = o.__menu.MenuElements;
    setmetatable(o, paginated_options_menu);
    return o
end