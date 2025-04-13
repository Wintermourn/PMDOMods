local ScreenKeyboard = {
    keyboards = {}
}

local createKeyboard = require 'screenkeyboard.lib.create_keyboard';

ScreenKeyboard.keyboards.previousEntries = nil;
ScreenKeyboard.keyboards.alphanumeric = createKeyboard('[$screenkeyboard:keyboard/alphanumeric]','[color=#00aaff][$screenkeyboard:keyboard/alphanumeric]', {
    "abcdefghijklm¡!",
    "nopqrstuvwxyz¿?",
    "␣    ♂♀|♡^    ␣",
    "ABCDEFGHIJKLM‘’",
    "NOPQRSTUVWXYZ“”",
    "1234567890:+-,."
});
ScreenKeyboard.keyboards.alphanumeric.grid[2][0].replacement = ' ';
ScreenKeyboard.keyboards.alphanumeric.grid[2][14].replacement = ' ';
ScreenKeyboard.keyboards.symbols = createKeyboard('[$screenkeyboard:keyboard/symbol]','[color=#ffaaff][$screenkeyboard:keyboard/symbol]', {
    "\u{E081}\u{E082}\u{E083}\u{E084}\u{E085}\u{E086}\u{E087}\u{E088}\u{E089}\u{E08A}\u{E08B}\u{E08C}\u{E08D}\u{E08E}\u{E08F}",
    " \u{E090}\u{E091}\u{E092}\u{E10A}\u{E10B}\u{E10C}\u{E10D}\u{E110}\u{E111}\u{F01F}\u{F020}\u{F021}\u{F022}",
    "␣ ;'\"()[]{}\\| ␣",
    "\u{E041}\u{E042}\u{E043}\u{E044}\u{E045}\u{E046}\u{E047}\u{E048}\u{E049}\u{E04A}\u{E04B}\u{E04C}\u{E04D}<>",
    "\u{E04E}\u{E04F}\u{E050}\u{E051}\u{E052}\u{E053}\u{E054}\u{E055}\u{E056}\u{E057}\u{E058}\u{E059}\u{E05A}/*",
    "\u{E101}\u{E102}\u{E103}\u{E104}\u{E105}\u{E106}\u{E107}\u{E108}\u{E109}\u{E100}@#$%&"
});
ScreenKeyboard.keyboards.keycaps = createKeyboard('[$screenkeyboard:keyboard/keycap]','[color=#44aadd][$screenkeyboard:keyboard/keycap]', {
    "\u{F830}\u{F831}\u{F832}\u{F833}\u{F834}\u{F835}\u{F836}\u{F837}\u{F838}\u{F839}\u{F8DB}\u{F8DC}\u{F8DD}\u{F8C0}\u{F8BF}",
    "\u{F841}\u{F842}\u{F843}\u{F844}\u{F845}\u{F846}\u{F847}\u{F848}\u{F849}\u{F84A}\u{F84B}\u{F84C}\u{F84D}\u{F84E}\u{F84F}",
    "␣ \u{F850}\u{F851}\u{F852}\u{F853}\u{F854}\u{F855}\u{F856}\u{F857}\u{F858}\u{F859}\u{F85A} ␣",
    "\u{F870}\u{F871}\u{F872}\u{F873}\u{F874}\u{F875}\u{F876}\u{F877}\u{F878}\u{F879}\u{F87A}\u{F87B}\u{F86D}\u{F8E2}\u{F8DE}",
    "\u{F006} \u{F01A} \u{F005}  \u{F004} \u{F01B} \u{F007}\u{F86A}\u{F826}\u{F86B}",
    "\u{F000}\u{F001}\u{F002}\u{F003}\u{F00B}\u{F00C}\u{F00D}\u{F00E}\u{F01F}\u{F020}\u{F021}\u{F022}\u{F825}\u{F828}\u{F827}"
});

return ScreenKeyboard;