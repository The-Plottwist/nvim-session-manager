---@diagnostic disable: undefined-global, unused-local, need-check-nil
-- # ----------------------------------------------------------- #
-- #                    NEOVIM SESSION MANAGER                   #
-- # ----------------------------------------------------------- #

-- # ----------------------- Description ----------------------- #
-- # Layer around neovim sessions.
-- # Provides basic functionality.
-- # Enhanced usage with other plugins is aimed.
-- # Example: The-Plottwist/nvim-workspace-manager


local sessions = {}
local data_file = ""
local cur_session = ""
local cur_session_file = ""
local event_data = { augroup_name = "SessionManager" }
local notif_options = { title = "Session Manager" }

--initialize OS specific variables
local is_os_windows = false
local path_seperator = '/'
local function initialize()
    if vim.fn.has("win32") == 1 then
        is_os_windows = true
        path_seperator = '\\'
    end
end
initialize()

local check_session_cache = { id = -1, name = "" }
local function check_session(strName)

    if (check_session_cache["id"] ~= -1) and (strName == check_session_cache["name"]) then
        return check_session_cache["id"], check_session_cache["name"]
    end

    for i,j in pairs(sessions) do
        if j == strName then
            check_session_cache["id"] = i
            check_session_cache["name"] = j
            return i,j
        end
    end

    return -1, ""
end

local defaults = {
    events = { "VimLeavePre" },

    --from persistence.nvim: https://github.com/folke/persistence.nvim/blob/main/lua/persistence/config.lua
    save_options = { "buffers", "curdir", "tabpages", "winsize", "skiprtp" },

    session_dir = vim.fn.stdpath("state") .. path_seperator .. "sessions",
    default_session = "last_session",
}


local M = {}

function M.setup(tableOpts)

    --configure defaults
    defaults = vim.tbl_deep_extend("force", {}, defaults, tableOpts or {})

    --ensure directories
    if vim.fn.isdirectory(defaults.session_dir) == 0 then
        vim.fn.mkdir(defaults.session_dir, 'p')
    end

    --configure sessions
    data_file = defaults.session_dir .. path_seperator .. "session_data"
    local f = io.open(data_file, 'r')
    if f ~= nil then
        for i in f:lines() do
            table.insert(sessions, i)
        end
        io.close(f)
    end
    if next(sessions) == nil then M.add(defaults.default_session) end
    M.change_session(defaults.default_session, false)

    --setup user commands
    vim.cmd([[
        command! -nargs=0 SessionSave lua require("session-manager").save()
        command! -bang SessionLoad lua require("session-manager").load("<bang>")
        command! -nargs=1 SessionAdd lua require("session-manager").add("<args>")
        command! -nargs=1 SessionDel lua require("session-manager").del("<args>")
        command! -nargs=0 SessionList lua require("session-manager").list()
        command! -nargs=? -bang SessionChange lua require("session-manager").change_session("<args>", "<bang>")
        command! -nargs=0 SessionStopEvents lua require("session-manager").stop_events()
        command! -nargs=0 SessionStartEvents lua require("session-manager").start_events()
    ]])

    --trigger 'BufEnter' events if session is loaded before 'UIEnter'
    vim.api.nvim_create_autocmd("UIEnter", {
        pattern = '*',
        callback = function()
            vim.cmd([[
                let cur_tab = tabpagenr()
                silent tabdo edit
                exec cur_tab 'tabnext'
            ]])
        end
    })

    if next(defaults.events) == nil then
        return
    end

    M.start_events()
end

--from persistence.nvim: https://github.com/folke/persistence.nvim/blob/main/lua/persistence/config.lua
function M.save()

    local tmp = vim.o.sessionoptions
    vim.o.sessionoptions = table.concat(defaults.save_options, ",")
    vim.cmd("mksession! " .. cur_session_file)
    vim.o.sessionoptions = tmp
end

function M.load(boolDelBuffers)

    if (boolDelBuffers ~= false) and (boolDelBuffers ~= '!') then
        boolDelBuffers = true
    end

    if boolDelBuffers == true then
        vim.cmd("silent %bdelete!")
    end

    if vim.fn.filereadable(cur_session_file) then
        vim.cmd("silent source " .. cur_session_file)
    else
        vim.notify("Session file not readable", "error", notif_options)
    end
end

function M.add(strName)

    if (strName == nil) or (strName == "") then return end

    local i,_ = check_session(strName)
    if i ~= -1 then
        M.change_session(strName, false)
        M.save()
        return
    end

    table.insert(sessions, strName)

    local f = io.open(data_file, 'a')
    f:write(strName .. '\n')
    io.close(f)

    M.change_session(strName, false)
    M.save()
end

function M.del(strName)

    if (strName == nil) or (strName == "") then
        return
    elseif strName == cur_session then
        vim.notify("Cannot delete current session", "error", notif_options)
        return
    end

    local f = io.open(data_file, 'w')
    for i,j in pairs(sessions) do
        if j == strName then
            sessions[i] = ""
        elseif (j ~= nil) and (j ~= "") then
            f:write(j, '\n')
        end
    end
    io.close(f)
end

function M.list()
    for _,i in pairs(sessions) do
        print(i)
    end
end

function M.change_session(strName, boolLoad)

    if (strName == nil) or (strName == "") then
        strName = defaults.default_session
    end

    if (boolLoad ~= false) and (boolLoad ~= '!') then
        boolLoad = true
    end

    local i,_ = check_session(strName)
    if i ~= -1 then
        cur_session = strName
        cur_session_file = vim.fn.fnameescape(defaults.session_dir .. path_seperator .. strName .. ".vim")
        if boolLoad == true then M.load() end
        return
    end

    vim.notify("No such session", "error", notif_options)
end

function M.stop_events()
    vim.api.nvim_del_augroup_by_name(event_data.augroup_name)
end

function M.start_events()

    vim.api.nvim_create_augroup(event_data.augroup_name, {clear = true})

    for _,i in pairs(defaults.events) do
        vim.api.nvim_create_autocmd(i, {
            pattern = '*',
            callback = M.save,
            group = event_data.augroup_name
        })
    end
end

return M
