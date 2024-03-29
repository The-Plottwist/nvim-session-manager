# NVIM SESSION MANAGER

A single layer implementation.
  
Standalone, no dependencies.
  
Can be used with [nvim workspace manager](https://github.com/The-Plottwist/nvim-workspace-manager).
  
  
### User Commands:

|Name|Description|
|---|---|
|SessionAdd|Add session <br>- Uses directory name if no argument is given|
|SessionDel|Delete session|
|SessionList|List sessions|
|SessionChange[!]|Change session <br>- Defaults to *```last_session```* if no argument is given <br>- If used with bang, session won't be loaded|
|SessionSave|Save session|
|SessionLoad[!]|Load session <br>- If used with bang, existing buffers won't be deleted (useful during startup)|
|SessionName|Print current session name|
|SessionRename|Rename current session|
|SessionStartEvents|Start events <br>- Events when to save a session, default is: VimLeavePre|
|SessionStopEvents|Stop events|
  
  
### Functions:
|Name|Description|
|---|---|
|add(strName)|Adds a session <br>- Optional: *```strName = CURRENT_WORKING_DIRECTORY```*|
|del(strName)|Deletes a session <br>- Mandatory: *```strName```* <br>- Returns immidiately if no argument is given|
|list()|Lists sessions|
|rename(strName)|Renames current session <br>- Mandatory: *```strName```*|
|change_session(strName, boolLoad)|Changes session <br>- Optional: *```strName = last_session```* <br>- Optional: *```boolLoad = true```*|
|save()|Saves current session|
|load(boolDelBuffers)|Loads current session <br>- Optional: *```boolDelBuffers = true```*|
|start_events()|Starts events|
|stop_events()|Stops events|
|get_session_name(boolPrint)|Returns current session name <br>- Optional: *```boolPrint = false```*|
  
  
### Installation:
Lazy.nvim
```lua
{
    "The-Plottwist/nvim-session-manager",
    branch = "stable"
}
```
  
  
### Defaults:
```lua
defaults = {
    events = {"VimPreLeave"},

    --For more info: help sessionoptions
    save_options = { "blank", "buffers", "curdir", "help", "skiprtp", "tabpages", "winsize", "winpos" },

	
    session_dir = vim.fn.stdpath("state") .. path_seperator .. "sessions",
	
    default_session = "last_session"
}
```
  
  
**Notes**
  
-To modify: *```require("session-manager").setup({events = {}, ...})```*
  
-Does not load any sessions by default
  
-Adds an ungrouped *```UIEnter```* event seperate from User events to refresh buffers when a session is loaded before UI (Gives error on empty tabpages, please close empty tabs).
  
  
### Example Usage:
```lua
--enable the plugin
require("session-manager").setup()

--check if a file argument is given at vim start
vim.cmd("let g:ARGC = argc()")

--load last_session if no file argument is given
if vim.g.ARGC == 0 then
    require("session-manager").load()
end
```
  
-No need to assign to a variable like ```manager = require(...)``` as lua stores all require calls as table values where described in the section [8.1 of Programming in Lua:](https://www.lua.org/pil/8.1.html) *"[...]it keeps a table with the names of all loaded files. If a required file is already in the table, require simply returns."* (Not recommended outside of configuration files)
  
  
