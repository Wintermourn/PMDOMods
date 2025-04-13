# On-Screen Keyboard
Work in progress mod to automatically show a controller supported keyboard whenever a supported input menu opens.
## How to use
Simply place into the `MODS` folder and enable in-game!
Currently has some additional inputs for controllers:
- Left/Right Trigger jumps left/right 5 characters on the keyboard
- Left Face (Square/X) deletes the last character
- Top Face (Triangle/Y) adds a space

## Todo
- [ ] Support ScriptableMenu (+ implement some way to validate character inputs)
    - Currently partial (checks for element with label `TEXT_ENTRY`)
- [ ] Support non-matching menu types
    - maybe have `screenkeyboard.RegisterMenu(menu, input)`?
- [ ] Stop keyboard from closing when the input menu refuses to close (e.g. blank input in team name entry)
- [ ] Option to auto close/open whenever keyboard key/gamepad button is pressed
    - Likely not possible without some global input event (or maybe just have an invisible/offscreen menu to pass input through?)
- [ ] Support PMD's keyboard inputs
    - [ ] RB+DPad = Shift entry spot
    - [ ] Start = Move to end
    - [ ] Select = Switch keyboard
    - [ ] Circle/B = Cancel
