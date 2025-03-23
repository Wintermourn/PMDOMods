# Menu Toolkit Documentation
## Menu Types
### Reflowing Options (`mentoolkit.menus.reflowing_options`)
An automatically reflowing options menu. This means that having too many options on one page will push later options onto another page.
#### Elements
##### Header (`reflowing:AddHeader(label)`)
Adds non-selectable text to the menu, shifted to the left.
##### Text (`reflowing:AddText(label)`)
Adds non-selectable text to the menu.
##### Button (`reflowing:AddButton(label, onSelected)`)
##### Submenu Button (`reflowing:AddButton(label, onSelected)`)
The same as a standard button, but it automatically sets the right label to `>` to indicate further options.
##### Spacer (`reflowing:AddSpacer(height)`)
Adds a divider to the page, pushing later options down by a specified height.
##### Page Break (`reflowing:PageBreak()`)
Automatically fills the rest of the current page, forcing further elements onto the next.
### Tactile (`mentoolkit.menus.tactile`)
Text-only menu for reading purposes. Supports pages of text and scrolling if they're too long.
***Note:*** Text does not automatically wrap horizontally.
#### Elements
##### Page (`tactile:CreatePage()`)
Creates a new page in the menu. From here, you can append and insert text (`Append(string)` and `Insert(line, string)`)