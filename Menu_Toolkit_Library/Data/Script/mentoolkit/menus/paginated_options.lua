local CONST = require 'mentoolkit.lib.constants'
    local Dir8 = CONST.Enums.Dir8;
    local DirH = CONST.Enums.DirH;

---@class mentoolkit.PaginatedOptions : mentoolkit.Menu
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
    ---Requires `title` to not be nil.
    ---@type boolean
    showPageNumber = true,
    ---The currently viewed page. Refresh for the user with page:Rebuild().
    currentPage = 1,
    ---The currently selected option.
    currentSelection = 1,
    ---@type any
    cursor = nil,
    ---@type mentoolkit.PaginatedOptions.Page[]
    pages = {},
    ---Additional `IMenuElement`s to be added and kept when rebuilding the menu.
    elements = {},
    --- Description box data, handled by the menu automatically.
    __description = {
        menu = nil, title = '', description = ''
    },
    actions = {}
}
paginated_options_menu.__index = paginated_options_menu;

---@class mentoolkit.PaginatedOptions.Page
local options_page = {
    ---@type mentoolkit.PaginatedOptions
    __owner = nil,
    ---@type mentoolkit.PaginatedOptions.Labelled[]
    contents = {},
    additionalElements = {}
}
options_page.__index = options_page;

---@class mentoolkit.PaginatedOptions.Labelled
---A labelled page entry, capable of showing text and being pressed, if desired.
local labelled = {
    ---@type mentoolkit.PaginatedOptions.Page
    __owner = nil,
    __menuElements = {},
    --- Can this element be pressed?
    enabled = true,
    --- Can this element be seen?
    visible = true,
    --- Can this element be skipped by the cursor?
    selectable = true,
    --- X and Y position for the cursor to be placed when hovered.
    cursorAnchor = RogueElements.Loc(0,0),
    --- How many pixels away from the window's left that the object should be able to reach.
    left = 16,
    ---Do not modify directly.<br>Use `labelled:SetLabel(direction, text)` instead.
    labels = {},
    ---Only applies to labels with dividers.
    dividerHeight = 0,
    actions = {
        --- fires when the element is selected/pressed.
        ---@type fun(self: mentoolkit.PaginatedOptions.Labelled)
        onSelected = nil,
        --- fires when the page the element is on is built (shown to the user).
        ---@type fun(self: mentoolkit.PaginatedOptions.Labelled)
        onRefresh = nil,
        --- fires when the elements is selected and the user moves left or right.
        --- * not yet implemented
        ---@type fun(self: mentoolkit.PaginatedOptions.Labelled, direction: -1|1, shiftHeld: boolean)
        onSlide = nil
    }
}
labelled.__index = labelled;

--- Rebuilds the current menu, readjusting positions and showing items from the current page.
function paginated_options_menu:Rebuild ()
    self.__menuElements:Clear();

    local mw = self.__menu.Bounds.Width;
    local mh = self.__menu.Bounds.Height;
    local y = 8;
    if self.title then
        if not self.__cache.hasTitle then
            self.__cache.hasTitle = true;
            self.__cache.globalElements.title = CONST.Functions.Menu.CreateText(require 'mentoolkit.lib.tag_reader' .parse(self.title), 10, 8);
            self.__cache.globalElements.divider = RogueEssence.Menu.MenuDivider(RogueElements.Loc(10,21), mw- 20);
        end
        if self.showPageNumber then
            if not self.__cache.hasPage then
                self.__cache.hasPage = true;
                self.__cache.globalElements.page =
                    CONST.Functions.Menu.CreateText(string.format('(%s/%s)',self.currentPage,#self.pages), mw - 10, 8, DirH.RIGHT);
            end
            self.__cache.globalElements.page:SetText(string.format('(%s/%s)', self.currentPage, #self.pages));
            self.__menuElements:Add(self.__cache.globalElements.page);
        end
        self.__menuElements:Add(self.__cache.globalElements.title);
        self.__menuElements:Add(self.__cache.globalElements.divider);

        y = y + 18;
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
                k.__menuElements.divider.Loc = RogueElements.Loc(k.__menuElements.divider.Loc.X, y);
                self.__menuElements:Add(k.__menuElements.divider);
                y = y + k.dividerHeight;
            end
            ::skip_element::
        end
    end

    self.__menuElements:Add(self.cursor);

    for i,k in pairs(self.elements) do
        self.__menuElements:Add(k);
    end
end

function paginated_options_menu:CursorTo(pageNum, elementNum)
    self.currentPage = pageNum; self.currentSelection = elementNum;
    self.cursor.Loc = self.pages[self.currentPage].contents[self.currentSelection].cursorAnchor;
    self:Rebuild();
end

--- Opens the menu, showing it to the user.
---@param rebuild boolean Whether the menu should "rebuild", repositioning all visible elements.
function paginated_options_menu:Open (rebuild)
    self.currentSelection = 1;
    self.pages[self.currentPage]:Refresh();
    if rebuild then self:Rebuild() end
    if self.pages[self.currentPage] then
        local page = self.pages[self.currentPage];
        local entry = page.contents[self.currentSelection];
        if entry then
            if not entry.selectable or not entry.visible then
                repeat
                    self.currentSelection = self.currentSelection + 1;
                    entry = page.contents[self.currentSelection];
                until entry.selectable or self.currentSelection == #page.contents;
            end
            if self.__description.menu then
                if entry and entry.description then
                    self:SetDescription(entry.description.title, entry.description.content);
                end
            end
            self.cursor.Loc = entry.cursorAnchor;
        end
    end

    --[[ if self.__description.menu then
        _MENU:AddMenu(self.__description.menu, true);
    end ]]
    _MENU:AddMenu(self.__menu, true);
end

--- Creates a description panel for menu options to explain themselves.
---@param x integer Menu X Position
---@param y integer Menu Y Position
---@param w integer Menu Width
---@param h integer Menu Height
---@return nil
function paginated_options_menu:AddDescriptionPanel(x,y,w,h)
    if self.__description.menu then return self.__description.menu; end
    self.__description.menu = RogueEssence.Menu.SummaryMenu(RogueElements.Rect(x,y,w,h));
    self.__description.titleObject = CONST.Functions.Menu.CreateText('', 10, 8);
    self.__description.descriptionObject = RogueEssence.Menu.DialogueText('', RogueElements.Rect(10, 25,w-20,h-33), 13);
---@diagnostic disable-next-line: undefined-field
    local entries = self.__description.menu.Elements;
    entries:Add(self.__description.titleObject);
    entries:Add(RogueEssence.Menu.MenuDivider(RogueElements.Loc(10,21), w - 20));
    entries:Add(self.__description.descriptionObject);

    self.__menu.SummaryMenus:Add(self.__description.menu);
end

--- Sets the text contained in the description box if it exists.<br>
--- ⚠️ Make sure to create the description box first via `menu:AddDescriptionPanel`!
---@param title any
---@param description any
function paginated_options_menu:SetDescription(title, description)
    if not self.__description.menu then return end
    self.__description.titleObject:SetText(require 'mentoolkit.lib.tag_reader' .parse(title));
    self.__description.descriptionObject:SetAndFormatText(require 'mentoolkit.lib.tag_reader' .parse(description));
end

---@overload fun(self: mentoolkit.PaginatedOptions, event: 'onClose', fun: fun(self: mentoolkit.PaginatedOptions))
function paginated_options_menu:SetCallback(event, fun)
    self.actions[event] = fun;
end

--- Adds a new page to the end of the current menu.
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

--- Adds "header" text to the page which is skipped by the cursor automatically.
---@param label string The left aligned label for the header
---@return mentoolkit.PaginatedOptions.Labelled header
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

---@param label string The left aligned label for the element
---@return mentoolkit.PaginatedOptions.Labelled header
function options_page:AddText(label)
    local option = {
        __owner = self,
        labels = {},
        enabled = false,
        selectable = false,
        actions = {},
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

function options_page:AddSpacer(distance)
    local option = {
        __owner = self,
        labels = {},
        enabled = false,
        selectable = false,
        actions = {},
        left = 17,
        dividerHeight = distance,
        __menuElements = {}
    };
    option.lines = 0;
    setmetatable(option, labelled);
    option.__menuElements.divider = RogueEssence.Menu.MenuDivider(RogueElements.Loc(17,0), self.__owner.__menu.Bounds.Width - 27);
    self.contents[#self.contents+1] = option;
    return option;
end

--- Adds a button to the current menu page.
---@param label string The left aligned label for the button
---@param onSelected fun(self: mentoolkit.PaginatedOptions.Labelled) Fires when the button is selected/pressed
---@return mentoolkit.PaginatedOptions.Labelled button
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

--- Adds a button with pre-added arrow indicator.
---@param label string The left aligned label for the button
---@param onSelected fun(self: mentoolkit.PaginatedOptions.Labelled) Fires when the button is selected/pressed
---@return mentoolkit.PaginatedOptions.Labelled button
function options_page:AddSubmenuButton(label, onSelected)
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
    option:SetLabel('right', '>');
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
    text = require 'mentoolkit.lib.tag_reader' .parse(text):gsub("%[br%]",'\n');
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

local inputs = {
    ['close'] = function (menu, playSound)
        if playSound then _GAME:SE("Menu/Cancel"); end
        --[[ if menu.__description.menu then
            _MENU:RemoveMenu();
        end ]]
        _MENU:RemoveMenu();
        if menu.actions.onClose then
            menu.actions.onClose(menu);
        end
    end,
    ['confirm'] = function (menu, playSound)
        local options = menu.pages[menu.currentPage].contents;
        if options[menu.currentSelection] and options[menu.currentSelection].enabled then
            if playSound then _GAME:SE("Menu/Confirm"); end
            options[menu.currentSelection].actions.onSelected(options[menu.currentSelection]);
        end
    end,
    ['up'] = function (menu, playSound)
        local options = menu.pages[menu.currentPage].contents;
        menu.currentSelection = menu.currentSelection - 1;
        if menu.currentSelection == 0 then menu.currentSelection = #options end
        while not options[menu.currentSelection].visible or not options[menu.currentSelection].selectable do
            menu.currentSelection = menu.currentSelection - 1;
            if menu.currentSelection == 0 then menu.currentSelection = #options end
        end
        if playSound then _GAME:SE("Menu/Select"); end

        if options[menu.currentSelection].description then
            menu:SetDescription(options[menu.currentSelection].description.title, options[menu.currentSelection].description.content);
        end
        menu.cursor.Loc = (options[menu.currentSelection].cursorAnchor or menu.cursor.Loc);
        menu.cursor:ResetTimeOffset();
    end,
    ['down'] = function (menu, playSound)
        local options = menu.pages[menu.currentPage].contents;
        menu.currentSelection = menu.currentSelection % #options + 1;
        if menu.currentSelection == 0 then menu.currentSelection = #options end
        while not options[menu.currentSelection].visible or not options[menu.currentSelection].selectable do
            menu.currentSelection = menu.currentSelection % #options + 1;
        end
        if playSound then _GAME:SE("Menu/Select"); end

        if options[menu.currentSelection].description then
            menu:SetDescription(options[menu.currentSelection].description.title, options[menu.currentSelection].description.content);
        end
        menu.cursor.Loc = (options[menu.currentSelection].cursorAnchor or menu.cursor.Loc);
        menu.cursor:ResetTimeOffset();
    end,
    ['left'] = function (menu, playSound)
        local options = menu.pages[menu.currentPage].contents;
        menu.currentPage = menu.currentPage - 1;
        if menu.currentPage <= 0 then menu.currentPage = #menu.pages end
        options = menu.pages[menu.currentPage].contents;
        menu.currentSelection = 1;
        while not options[menu.currentSelection].visible or not options[menu.currentSelection].selectable do
            menu.currentSelection = menu.currentSelection % #options + 1;
        end
        if playSound then _GAME:SE("Menu/Select"); end

        if options[menu.currentSelection].description then
            menu:SetDescription(options[menu.currentSelection].description.title, options[menu.currentSelection].description.content);
        end
        menu.pages[menu.currentPage]:Refresh();
        menu:Rebuild();

        menu.cursor.Loc = (options[menu.currentSelection].cursorAnchor or menu.cursor.Loc);
        menu.cursor:ResetTimeOffset();
    end,
    ['right'] = function (menu, playSound)
        local options = menu.pages[menu.currentPage].contents;
        menu.currentPage = menu.currentPage % #menu.pages + 1;
        options = menu.pages[menu.currentPage].contents;
        menu.currentSelection = 1;
        while not options[menu.currentSelection].visible or not options[menu.currentSelection].selectable do
            menu.currentSelection = menu.currentSelection % #options + 1;
        end
        if playSound then _GAME:SE("Menu/Select"); end

        if options[menu.currentSelection].description then
            menu:SetDescription(options[menu.currentSelection].description.title, options[menu.currentSelection].description.content);
        end
        menu.pages[menu.currentPage]:Refresh();
        menu:Rebuild();

        menu.cursor.Loc = (options[menu.currentSelection].cursorAnchor or menu.cursor.Loc);
        menu.cursor:ResetTimeOffset();
    end
}

---@param input 'close'|'confirm'|'up'|'down'|'left'|'right'
---@param playSound boolean?
function paginated_options_menu:Input(input, playSound)
    if inputs[input] then inputs[input](self, playSound) end
end

---@param menu mentoolkit.PaginatedOptions
---@param input any (C# InputManager object)
---@return function|nil
local controls_listener = function (menu, input)
    if input:JustPressed(RogueEssence.FrameInput.InputType.Cancel) or input:JustPressed(RogueEssence.FrameInput.InputType.Menu) then
        paginated_options_menu.Input(menu, 'close', true);
        return;
    end

    if menu.onInput then if menu:onInput(input) then return end end

    if menu.pages[menu.currentPage] then
        if input:JustPressed(RogueEssence.FrameInput.InputType.Confirm) then
            paginated_options_menu.Input(menu, 'confirm', true);
            return;
        end

        if input.Direction == input.PrevDirection then return end
        if input.Direction == Dir8.UP then
            paginated_options_menu.Input(menu, 'up', true);
        elseif input.Direction == Dir8.DOWN then
            paginated_options_menu.Input(menu, 'down', true);
        elseif input.Direction == Dir8.LEFT then
            paginated_options_menu.Input(menu, 'left', true);
        elseif input.Direction == Dir8.RIGHT then
            paginated_options_menu.Input(menu, 'right', true);
        end
    end
end

---Paginated Options menu constructor
---@param x integer X Position
---@param y integer Y Position
---@param w integer Menu Width
---@param h integer Menu Height
---@return mentoolkit.PaginatedOptions
local createMenu = function(x, y, w, h)
    local o = {
        pages = {}, elements = {}, __cache = {hasTitle = false, globalElements = {}}, __description = {menu = nil, title = '', content = ''},
        actions = {}
    };
    o.__menu = RogueEssence.Menu.ScriptableMenu(x,y,w,h, function(i) controls_listener(o, i) end);
    o.cursor = RogueEssence.Menu.MenuCursor(o.__menu);
    o.__menuElements = o.__menu.Elements;
    setmetatable(o, paginated_options_menu);
    return o
end

return {
    create = createMenu,
    __metatables = {
        menu = paginated_options_menu,
        page = options_page,
        element = labelled
    }
}