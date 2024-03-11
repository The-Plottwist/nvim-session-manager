# NVIM SESSION MANAGER

A single layer implementation.
  
Standalone, no dependencies.
  
  
### User Commands:

|Name|Description|
|---|---|
|SessionAdd|Add session <br>- Uses directory name by default if no argument is given|
|SessionDel|Delete session|
|SessionList|List sessions|
|SessionChange[!]|Change session <br>- Defaults to ```last_session``` if no argument is given <br>- If used with bang, session won't be loaded|
|SessionSave|Save session|
|SessionLoad[!]|Load session <br>- If used with bang, existing buffers won't be deleted (useful during startup)|
|SessionStartEvents|Start events <br>- Events when to save a session, default is: VimLeavePre|
|SessionStopEvents|Stop events|
  
  
### Functions:
|Name|Description|
|---|---|
|add(strName)|Adds a session <br>- Optional: ```strName = CURRENT_WORKING_DIRECTORY``` by default|
|del(strName)|Deletes a session <br>- Mandatory: ```strName``` <br>- Returns immidiately if no argument is given|
|list()|Lists sessions|
|change_session(strName, boolLoad)|Changes session <br>- Optional: ```strName = last_session``` by default <br>- Optional: ```boolLoad = true``` by default|
|save()|Saves current session|
|load(boolDelBuffers)|Loads current session <br>- Optional: ```boolDelBuffers = true``` by default|
|start_events()|Starts events|
|stop_events()|Stops events|
|get_session_name()|Returns current session name|
  
  
### Default Options:
```lua
defaults = {
	events = {"VimPreLeave"},

	--from persistence.nvim
	save_options = { "buffers", "curdir", "tabpages", "winsize", "skiprtp" },
	
	session_dir = vim.fn.stdpath("state") .. path_seperator .. "sessions",
	
	default_session = "last_session"
}
```
  
-To modify defaults: ```require("session-manager").setup({events = {}, ...})```
  
-Does not load any session by default
  
-[Persistence.nvim](https://github.com/folke/persistence.nvim/blob/main/lua/persistence/config.lua)
  
  
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
  
-No need to assign to a variable like ```manager = require(...)``` as lua stores all require calls as table values rather than calling the function every time as described in the section [8.1 of Programming in Lua:](https://www.lua.org/pil/8.1.html) *"[...]it keeps a table with the names of all loaded files. If a required file is already in the table, require simply returns."* (Not recommended outside of configuration files)
  
  
