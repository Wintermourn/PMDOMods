---@class Color : any
---@class Loc

local input = luanet.namespace("Microsoft.Xna.Framework.Input");
local CONST = {
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
        },
        Keys = {
            Escape = input.Keys.Escape,
            Backspace = input.Keys.Back,
            Space = input.Keys.Space
        },
        Buttons = {
            LeftShoulder = input.Buttons.LeftShoulder,
            RightShoulder = input.Buttons.RightShoulder,
            LeftTrigger = input.Buttons.LeftTrigger,
            RightTrigger = input.Buttons.RightTrigger,
            FaceLeft = input.Buttons.X,
            FaceTop = input.Buttons.Y
        }
    },
    Classes = {
        System = {
            Object = luanet.import_type('System.Object'),
            BindingFlags = luanet.import_type('System.Reflection.BindingFlags')
        }
    },
    Functions = {Menu = {}}
};

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