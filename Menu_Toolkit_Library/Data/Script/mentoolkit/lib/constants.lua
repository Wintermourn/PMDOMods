---@class Color : any
---@class Loc

local CONST = {
    FUNCTION_EMPTY = function () end,
    TEXT_START = RogueElements.Loc(2, 1),
    Enums = {
        ---@enum RogueElements.DirV
        DirV = {
            UP = RogueElements.DirV.Up,
            NONE = RogueElements.DirV.None,
            DOWN = RogueElements.DirV.Down
        },
        ---@enum RogueElements.DirH
        DirH = {
            LEFT = RogueElements.DirH.Left,
            NONE = RogueElements.DirH.None,
            RIGHT = RogueElements.DirH.Right
        },
        Dir8 = {
            NONE = RogueElements.Dir8.None,
            UP = RogueElements.Dir8.Up,
            DOWN = RogueElements.Dir8.Down,
            LEFT = RogueElements.Dir8.Left,
            RIGHT = RogueElements.Dir8.Right,
        }
    },
    Functions = {
        CLOSE_MENU = function () _MENU:RemoveMenu() end,
        Menu = {}
    },
    Methods = {
        ---@type fun(x: integer, y: integer): Loc
        Location = RogueElements.Loc,
        String = {},
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
        }
    }
};

---@param title string
---@param action fun()
---@param height_offset integer
---@return unknown
CONST.Functions.Menu.TextChoice = function (title, action, height_offset)
    local choice = CONST.Methods.Menu.Elements.TextChoice(title, action);
    local b = choice.Bounds;
    b.Height = b.Height + height_offset;
    choice.Bounds = b;

    return choice;
end

---@param text string
---@param x integer
---@param y integer
---@param horizontal_align RogueElements.DirH?
---@param vertical_align RogueElements.DirV?
---@return unknown
CONST.Functions.Menu.CreateText = function (text, x, y, horizontal_align, vertical_align)
    if vertical_align and horizontal_align then
        return RogueEssence.Menu.MenuText(
            text, RogueElements.Loc(x, y),
            vertical_align,
            horizontal_align, Color.White);
    elseif horizontal_align then
        return RogueEssence.Menu.MenuText(
            text, RogueElements.Loc(x, y),
            horizontal_align);
    else
        return RogueEssence.Menu.MenuText(
            text, RogueElements.Loc(x, y));
    end
end

return CONST;