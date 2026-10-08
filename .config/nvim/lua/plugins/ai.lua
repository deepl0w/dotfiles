-- Don't load AI/Copilot plugins when running inside VSCode
if vim.g.vscode then
    return {}
end

-- ── Claude Code: the pane is a viewer, not the session ──────────────────────
--
-- Switching conversations must not cost you the one you are leaving, and
-- `/resume` cannot promise that: it re-purposes the process it runs in, so
-- whatever that process was working on stops unless you remembered to `/bg`
-- first. A session that lives in the pane is fragile for the same reason --
-- `terminal.close()` wipes the terminal buffer (Snacks does the wiping) and the
-- job goes with it.
--
-- So no session lives in the pane. Each one is created daemon-hosted
-- (`claude --bg`, which prints a short id) and the pane runs `claude attach <id>`
-- -- a client that owns nothing. Hide it, close it, replace it, quit Neovim: none
-- of that reaches the conversation. Switching is just attaching a different id,
-- so the session you leave keeps working and `/bg` never has to be remembered.
-- <leader>ar picks one in telescope, "＋ new session" included.
--
-- `/resume` inside the pane still re-purposes the session it runs in -- it is the
-- one gesture to avoid now that the picker does the switching.
--
-- Ending a session stays deliberate, and outside Neovim's reach: `/exit` in the
-- pane, or `claude stop <id>` (the agents view, `←` in the prompt, lists them).
--
-- What the daemon costs us: its host process never sees CLAUDE_CODE_SSE_PORT, so
-- a session has no editor link of its own -- and any link it had is stale after a
-- Neovim restart. Nothing fixes that from the outside (--ide is not forwarded to
-- the daemon's spare host, autoConnectIde does not fire for a background session
-- or on attach); only `/ide` from inside works, so link_editor() types it -- but
-- ONLY into a session it just created, where the input box is known to be empty.
-- Attach anything pre-existing and you get a note asking you to type /ide, which
-- is the difference between an automation and a keylogger with opinions.

local claude = {}

-- Sessions this Neovim started or attached, per project root. In memory on
-- purpose: <leader>ar reaches everything still running, but a fresh Neovim opens
-- a fresh conversation instead of silently adopting one.
local current = {}

-- Wrapped claudecode.terminal functions: our own calls go to these, so they never
-- bounce back through the wrappers, and orig.close can still empty the pane.
local orig = {}

-- Sessions we started are named for their project, so the picker can prefer them
-- over a background agent someone dispatched in the same repo for other work.
local BG_NAME_PREFIX = "nvim:"

local function notify(msg, level)
    vim.notify("claude: " .. msg, level or vim.log.levels.INFO)
end

local function strip_ansi(s)
    return (tostring(s or ""):gsub("\27%[[%d;?]*%a", ""))
end

local function project_root()
    local cwd = (vim.uv or vim.loop).cwd() or vim.fn.getcwd()
    local ok, root = pcall(vim.fs.root, cwd, ".git")
    if ok and type(root) == "string" and root ~= "" then
        return root
    end
    return cwd
end

local function term()
    local ok, t = pcall(require, "claudecode.terminal")
    return ok and t or nil
end

local function pane_bufnr()
    local t = term()
    local bufnr = t and t.get_active_terminal_bufnr()
    if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
        return bufnr
    end
    return nil
end

-- What the pane is running, straight from the process: `claude attach <id>` is a
-- client onto a daemon-hosted session, anything else (`:ClaudeCode --resume`, say)
-- is a session in its own right and has to be backgrounded rather than dropped.
local function pane_argv(bufnr)
    local pid = bufnr and vim.b[bufnr] and vim.b[bufnr].terminal_job_pid
    if not pid then
        return nil
    end
    local fd = io.open("/proc/" .. pid .. "/cmdline", "r")
    if not fd then
        return nil
    end
    local argv = fd:read("*a")
    fd:close()
    return (tostring(argv or ""):gsub("%z", " "))
end

local function pane_session_id(bufnr)
    return (pane_argv(bufnr) or ""):match("attach%s+(%x+)")
end

-- chansend, not terminal.send_to_terminal: that one rewrites carriage returns and
-- wraps multi-line text in bracketed paste, which mangles the raw keys (Enter, Up)
-- the /ide picker reads.
local function send_raw(bufnr, data)
    local chan = (vim.b[bufnr] and vim.b[bufnr].terminal_job_id) or vim.bo[bufnr].channel
    if not chan or chan == 0 then
        return false
    end
    local ok, written = pcall(vim.fn.chansend, chan, data)
    return ok and written ~= 0
end

local function claude_cli(args, opts, cb)
    local cmd = vim.list_extend({ "claude" }, args)
    opts = vim.tbl_extend("keep", opts or {}, { text = true })
    vim.system(cmd, opts, function(res)
        vim.schedule(function()
            cb(res)
        end)
    end)
end

-- root nil lists every background session, whatever project it belongs to.
local function list_sessions(root, cb)
    local args = { "agents", "--json" }
    if root then
        vim.list_extend(args, { "--cwd", root })
    end
    claude_cli(args, {}, function(res)
        if res.code ~= 0 then
            notify("`claude agents` failed: " .. vim.trim(strip_ansi(res.stderr)), vim.log.levels.ERROR)
            return cb({})
        end
        local ok, decoded = pcall(vim.json.decode, res.stdout or "")
        if not ok or type(decoded) ~= "table" then
            return cb({})
        end
        local sessions = {}
        for _, agent in ipairs(decoded) do
            -- Only background sessions have an id to attach to; an "interactive"
            -- entry is a terminal somewhere else, running its own process.
            if agent.kind == "background" and type(agent.id) == "string" then
                sessions[#sessions + 1] = agent
            end
        end
        table.sort(sessions, function(a, b)
            return (a.startedAt or 0) > (b.startedAt or 0)
        end)
        cb(sessions)
    end)
end

-- This project's session: the one we were last in if it is still running, else
-- the newest we started here. Never an unnamed agent -- those are someone else's
-- work, and <leader>ar is where you go to attach one deliberately.
local function resolve_session(root, cb)
    list_sessions(root, function(sessions)
        local mine
        for _, session in ipairs(sessions) do
            if session.id == current[root] then
                return cb(session)
            end
            local name = type(session.name) == "string" and session.name or ""
            if not mine and name:sub(1, #BG_NAME_PREFIX) == BG_NAME_PREFIX then
                mine = session
            end
        end
        current[root] = nil
        cb(mine)
    end)
end

local function create_session(root, cb)
    claude_cli({ "--bg", "-n", BG_NAME_PREFIX .. vim.fn.fnamemodify(root, ":t") }, { cwd = root }, function(res)
        local out = strip_ansi((res.stdout or "") .. (res.stderr or ""))
        -- "backgrounded · <id> · <name>" and a few hint lines; the "claude attach
        -- <id>" hint is the unambiguous place to read the id from. (--session-id
        -- is no help: --bg says so and mints its own.)
        local id = out:match("claude attach (%x+)")
        if not id then
            notify("could not start a session:\n" .. vim.trim(out), vim.log.levels.ERROR)
        end
        -- __fresh marks the one case where typing into a session is safe: see attach().
        cb(id and { id = id, status = "idle", __fresh = true } or nil)
    end)
end

-- Hide, never close. simple_toggle on a visible pane is exactly a hide, and the
-- visibility check keeps it from re-showing a pane that is already hidden.
local function hide_pane()
    local bufnr = pane_bufnr()
    if not bufnr then
        return
    end
    for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
        local ok, cfg = pcall(vim.api.nvim_win_get_config, win)
        if not (ok and cfg and cfg.hide == true) then
            orig.simple_toggle({})
            return
        end
    end
end

-- One Neovim, many project roots -- but claudecode writes its lockfile once, at
-- server start, advertising only the cwd of that moment. Claude decides whether an
-- IDE is valid for a session by matching that workspaceFolders list against the
-- session's own cwd, so a session started anywhere else finds no valid IDE and
-- `/ide` says "their workspace/project directories do not match the current cwd".
--
-- One Neovim can only host one server, so instead of an IDE per root we keep the
-- one lockfile honest about every root we work in: get_workspace_folders() is where
-- claudecode builds that list and it is consulted on every write, so extend it and
-- rewrite the file with the server's own token -- same pid, same token, so live
-- connections are undisturbed.
local advertised = {}

local function advertise(...)
    -- The current cwd goes in every time: upstream's builder adds it, so leaving it
    -- out of our own set would silently drop it from the list the next time we
    -- rewrite the file from somewhere else.
    for _, dir in ipairs({ vim.fn.getcwd(), ... }) do
        if type(dir) == "string" and dir ~= "" then
            advertised[dir] = true
        end
    end
    -- Always rewrite, never "only if the set grew": DirChanged below records roots
    -- without touching the file, so a grown-set test would skip the one write that
    -- actually matters -- the one right before a session in that root runs /ide.
    local cc = require("claudecode")
    local port = cc.state and cc.state.port
    if not port or not cc.state.auth_token then
        return -- server not up yet; whoever writes the lockfile next picks the list up
    end
    local ok, err = require("claudecode.lockfile").create(port, cc.state.auth_token)
    if not ok then
        notify("could not refresh the IDE lockfile: " .. tostring(err), vim.log.levels.WARN)
    end
end

-- Drives `/ide` in the pane: Enter runs the command, Up moves off the selected
-- "None" onto Neovim, Enter accepts. Idle sessions only -- a busy one takes
-- keystrokes as queued prompt text instead of acting on them.
--
-- Retried, because a session `claude --bg` only just created can still be booting
-- when the pane is up: each round is a no-op once the link is there, so the cost
-- of an early attempt is nothing.
function claude.link_editor(opts)
    opts = opts or {}
    local attempts = opts.attempts or 1
    local cc = require("claudecode")
    vim.defer_fn(function()
        local bufnr = pane_bufnr()
        if not bufnr then
            return
        end
        if opts.only_if_unlinked and cc.is_claude_connected() then
            return
        end
        if not send_raw(bufnr, "/ide\r") then
            return
        end
        vim.defer_fn(function()
            local picker = pane_bufnr()
            if picker then
                send_raw(picker, "\27[A")
            end
            vim.defer_fn(function()
                local confirm = pane_bufnr()
                if confirm then
                    send_raw(confirm, "\r")
                end
                vim.defer_fn(function()
                    if cc.is_claude_connected() then
                        return
                    end
                    if attempts > 1 and pane_bufnr() then
                        claude.link_editor({ delay = 3000, only_if_unlinked = true, attempts = attempts - 1 })
                    else
                        notify("editor not linked -- run /ide in the pane", vim.log.levels.WARN)
                    end
                end, 2000)
            end, 400)
        end, 1500)
    end, opts.delay or 0)
end

-- Only reached by a pane that owns its session (`:ClaudeCode --resume` and the
-- like): `/bg` hands it to the daemon, the work carries on and the CLI exits.
-- Blocking on purpose -- we are about to spawn into that pane.
local function background_pane(bufnr, timeout)
    local job = bufnr and vim.b[bufnr] and vim.b[bufnr].terminal_job_id
    if not job or job == 0 then
        return true
    end
    if not send_raw(bufnr, "/bg\r") then
        return false
    end
    local exited = vim.wait(timeout or 10000, function()
        return vim.fn.jobwait({ job }, 0)[1] ~= -1
    end, 100)
    if not exited then
        notify("/bg did not detach the pane's session; left it running", vim.log.levels.WARN)
    end
    return exited
end

-- Let auto_close finish tearing the old pane down before spawning into it: the
-- wiped buffer's BufWipeout handler clears the plugin's terminal state and would
-- otherwise orphan the pane we are about to create.
local function await_pane_gone(timeout)
    if not pane_bufnr() then
        return true
    end
    return vim.wait(timeout or 3000, function()
        return pane_bufnr() == nil
    end, 50)
end

-- Empty the pane without ending anything.
local function free_pane()
    local bufnr = pane_bufnr()
    if not bufnr then
        return true
    end
    if pane_session_id(bufnr) then
        orig.close() -- a client; its session is the daemon's and keeps running
    elseif background_pane(bufnr) then
        if not await_pane_gone() then
            orig.close() -- auto_close disabled: drop the exited CLI's buffer
        end
    else
        return false -- /bg refused; leave that session where it is
    end
    await_pane_gone(1000)
    return pane_bufnr() == nil
end

local function attach(session, opts)
    opts = opts or {}
    local t = term()
    if not t or not session or not free_pane() then
        return
    end
    -- Both roots matter: the session's own cwd is what its /ide picker matches
    -- against, and this Neovim's is what it will still be editing in.
    advertise(project_root(), session.cwd)
    orig.open({}, "attach " .. session.id)
    current[project_root()] = session.id
    if opts.focus == false then
        vim.cmd("stopinsert")
        vim.cmd("wincmd p")
    end
    -- Typing into a session is only safe when we just created it: the input box is
    -- empty, no conversation is under way, and Neovim is the one IDE its /ide
    -- picker will offer. A session that already existed may have queued text --
    -- keystrokes concatenate with it and get submitted as a message -- or belong to
    -- another project, whose picker offers no Neovim at all and answers "No IDE
    -- selected". Those get a note instead of a robot.
    if session.__fresh then
        claude.link_editor({ delay = 2500, only_if_unlinked = true, attempts = 4 })
    elseif not require("claudecode").is_claude_connected() then
        notify("attached " .. session.id .. " -- type /ide in the pane to link this editor")
    end
end

local resolving = false

-- Opening the pane on an empty slate: attach this project's session, starting one
-- the first time.
local function open_session(opts)
    if resolving then
        return -- one resolve at a time; two panes would race
    end
    resolving = true
    local root = project_root()
    advertise(root) -- before the session exists, so its /ide sees a valid IDE
    resolve_session(root, function(session)
        if session then
            resolving = false
            return attach(session, opts)
        end
        create_session(root, function(created)
            resolving = false
            attach(created, opts)
        end)
    end)
end

local function describe(session, root)
    if session.__new then
        return "＋ new session"
    end
    local age = "?"
    if type(session.startedAt) == "number" then
        local mins = math.max(0, math.floor((os.time() * 1000 - session.startedAt) / 60000))
        age = mins < 60 and (mins .. "m ago") or (math.floor(mins / 60) .. "h ago")
    end
    -- Only name the project for sessions from somewhere else; in one Neovim that
    -- works every repo, that is the column that tells them apart.
    local elsewhere = ""
    if root and session.cwd and not vim.startswith(session.cwd, root) then
        elsewhere = "  ·  " .. vim.fn.fnamemodify(session.cwd, ":~")
    end
    return string.format(
        "%s  ·  %s  ·  %s%s  (%s)",
        session.name or session.id,
        session.status or "?",
        age,
        elsewhere,
        session.id
    )
end

-- The picker's rows: every background session there is, whoever started it and
-- wherever from -- attaching one costs the session in the pane nothing. This
-- project's sort first, then "＋ new session" on top.
local function session_choices(root, cb)
    list_sessions(nil, function(sessions)
        table.sort(sessions, function(a, b)
            local a_here = (a.cwd or ""):sub(1, #root) == root
            local b_here = (b.cwd or ""):sub(1, #root) == root
            if a_here ~= b_here then
                return a_here
            end
            return (a.startedAt or 0) > (b.startedAt or 0)
        end)
        table.insert(sessions, 1, { __new = true })
        cb(sessions)
    end)
end

-- Two ways out of the picker, because they are not the same thing: `claude stop`
-- ends the process but keeps the conversation (`claude --resume` brings it back),
-- while `claude rm` deletes it. Only the second one asks.
local function end_session(session, permanent, done)
    if session.__new then
        return
    end
    local label = session.name and (session.name .. " (" .. session.id .. ")") or session.id
    if permanent and vim.fn.confirm("Delete " .. label .. " and its conversation?", "&Yes\n&No", 2) ~= 1 then
        return
    end
    claude_cli({ "stop", session.id }, {}, function()
        if not permanent then
            notify("stopped " .. label .. " -- `claude --resume` brings it back")
            return done()
        end
        claude_cli({ "rm", session.id }, {}, function(res)
            local out = vim.trim(strip_ansi((res.stdout or "") .. (res.stderr or "")))
            notify(out ~= "" and out or ("removed " .. session.id))
            done()
        end)
    end)
end

-- Telescope, with what the session is actually doing in the preview pane.
-- `claude logs <id>` is a raw terminal dump -- escape codes, spinner frames, screen
-- redraws -- so it is unreadable as text but perfectly readable through a terminal
-- emulator, which is exactly what telescope's termopen previewer gives us: the
-- session's own screen, last frame wins. Costs a `claude logs` per selection
-- (~1.5s), which telescope's debounce keeps off the critical path.
local function pick_with_telescope(root, choices, on_choice)
    local ok_pickers, pickers = pcall(require, "telescope.pickers")
    if not ok_pickers then
        return false
    end
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local previewers = require("telescope.previewers")

    local function make_finder(rows)
        return finders.new_table({
            results = rows,
            entry_maker = function(session)
                return {
                    value = session,
                    display = describe(session, root),
                    ordinal = session.__new and "new"
                        or table.concat({ session.name or "", session.id, session.cwd or "" }, " "),
                }
            end,
        })
    end

    -- A stop or a delete leaves the list stale; rebuild it in place instead of
    -- closing the picker, so several can be cleared out in one visit.
    local function reload(prompt_bufnr)
        session_choices(root, function(rows)
            local picker = action_state.get_current_picker(prompt_bufnr)
            if picker then
                picker:refresh(make_finder(rows), { reset_prompt = false })
            end
        end)
    end

    pickers
        .new({}, {
            prompt_title = "Claude sessions  ·  <C-d> delete  ·  <C-s> stop",
            finder = make_finder(choices),
            sorter = conf.generic_sorter({}),
            previewer = previewers.new_termopen_previewer({
                title = "Session output",
                get_command = function(entry)
                    local session = entry.value
                    if session.__new then
                        return { "echo", "Start a new conversation in " .. vim.fn.fnamemodify(root, ":~") }
                    end
                    return { "claude", "logs", session.id }
                end,
            }),
            attach_mappings = function(prompt_bufnr, map)
                actions.select_default:replace(function()
                    local entry = action_state.get_selected_entry()
                    actions.close(prompt_bufnr)
                    if entry then
                        on_choice(entry.value)
                    end
                end)

                -- Both modes, and control keys only: filtering happens in insert
                -- mode, and a bare "d"/"s" is either prompt text or a normal-mode
                -- operator -- neither should delete a conversation. Shadowing
                -- telescope's insert <C-d> (scroll preview; <C-u> still scrolls the
                -- other way) and <C-s> (open in a split, meaningless here) is the
                -- price, and the global n-mode <c-d> (delete_buffer) does nothing
                -- useful for rows that are not buffers.
                local function bind(lhs, permanent)
                    map({ "i", "n" }, lhs, function()
                        local entry = action_state.get_selected_entry()
                        if entry then
                            end_session(entry.value, permanent, function()
                                reload(prompt_bufnr)
                            end)
                        end
                    end)
                end
                bind("<C-d>", true)
                bind("<C-s>", false)
                return true
            end,
        })
        :find()
    return true
end

function claude.pick()
    local root = project_root()
    advertise(root)
    session_choices(root, function(choices)
        local function choose(session)
            if not session.__new then
                return attach(session)
            end
            create_session(root, function(created)
                attach(created)
            end)
        end

        if pick_with_telescope(root, choices, choose) then
            return
        end
        vim.ui.select(choices, {
            prompt = "Claude sessions",
            format_item = function(session)
                return describe(session, root)
            end,
        }, function(session)
            if session then
                choose(session)
            end
        end)
    end)
end

-- Runs once, after claudecode.setup(), so these win over the plugin's own.
local function wire_session_lifecycle()
    local t = term()
    if not t then
        return
    end
    orig.close, orig.open, orig.ensure_visible, orig.simple_toggle =
        t.close, t.open, t.ensure_visible, t.simple_toggle

    -- Extend the lockfile's workspace list with every root we advertise (see
    -- advertise()). Patching the builder rather than the file means claudecode's
    -- own writes -- start, restart, :ClaudeCodeStart -- keep the extra roots.
    -- Replacing the pane's client means wiping its buffer, which kills the job;
    -- nvim reports that as status -1 and claudecode's auto_close handler turns it
    -- into "Claude exited with code -1. Check for any errors." There is nothing to
    -- check: -1 is nvim force-stopping a job, i.e. always us, and the client it
    -- killed was disposable -- its session is still running in the daemon. A real
    -- crash exits with a positive code and still gets reported.
    local logger = require("claudecode.logger")
    local upstream_error = logger.error
    logger.error = function(component, ...)
        if component == "terminal" then
            local msg = table.concat(vim.tbl_map(tostring, { ... }), "")
            if msg:find("exited with code -1", 1, true) then
                return
            end
        end
        return upstream_error(component, ...)
    end

    local lockfile = require("claudecode.lockfile")
    -- Seed the set with where Neovim started (no rewrite needed -- the lockfile
    -- already says so) and note every root visited after that, so a session you
    -- attach later in any of them still finds this editor valid.
    advertised[vim.fn.getcwd()] = true
    vim.api.nvim_create_autocmd("DirChanged", {
        group = vim.api.nvim_create_augroup("ClaudeWorkspaceRoots", { clear = true }),
        callback = function()
            advertised[vim.fn.getcwd()] = true
        end,
    })

    local upstream_folders = lockfile.get_workspace_folders
    lockfile.get_workspace_folders = function()
        local folders = upstream_folders()
        for dir in pairs(advertised) do
            if not vim.tbl_contains(folders, dir) then
                table.insert(folders, dir)
            end
        end
        return folders
    end

    t.close = function()
        hide_pane()
    end

    -- Every path that would otherwise spawn a session into the pane -- :ClaudeCode,
    -- :ClaudeCodeOpen, an @ mention with nothing running -- attaches instead.
    -- Explicit args (`:ClaudeCode --resume`) are left alone: that is the escape
    -- hatch, and free_pane() still `/bg`s whatever it leaves behind.
    local function guard(name, focus)
        t[name] = function(opts_override, cmd_args)
            if cmd_args or pane_bufnr() then
                return orig[name](opts_override, cmd_args)
            end
            open_session({ focus = focus })
        end
    end
    guard("open", true)
    guard("simple_toggle", true)
    guard("ensure_visible", false)

    vim.api.nvim_create_user_command("ClaudeCodeSessions", function()
        claude.pick()
    end, { desc = "Pick a running Claude session to open in the pane" })
end

return {
    -- Copilot Lua plugin (core)
    -- {
    --     "zbirenbaum/copilot.lua",
    --     requires = {
    --         "copilotlsp-nvim/copilot-lsp",
    --     },
    --     cmd = "Copilot",
    --     event = "InsertEnter",
    --     config = function()
    --         require("copilot").setup({
    --             suggestion = {
    --                 auto_trigger = true,
    --                 hide_during_completion = false,
    --             }, nes = {
    --                 enabled = false,
    --                 keymap = {
    --                     accept_and_goto = "<leader>l",
    --                     accept = false,
    --                     dismiss = "<Esc>",
    --                 },
    --             },
    --         })
    --     end,
    -- },
    -- -- Copilot LSP (experimental AI code actions)
    -- {
    --     "copilotlsp-nvim/copilot-lsp",
    --     init = function()
    --         vim.g.copilot_nes_debounce = 500
    --         vim.lsp.enable("copilot_ls")
    --         vim.keymap.set("n", "<tab>", function()
    --             local bufnr = vim.api.nvim_get_current_buf()
    --             local state = vim.b[bufnr].nes_state
    --             if state then
    --                 -- Try to jump to the start of the suggestion edit.
    --                 -- If already at the start, then apply the pending suggestion and jump to the end of the edit.
    --                 local _ = require("copilot-lsp.nes").walk_cursor_start_edit()
    --                 or (
    --                     require("copilot-lsp.nes").apply_pending_nes()
    --                     and require("copilot-lsp.nes").walk_cursor_end_edit()
    --                 )
    --                 return nil
    --             else
    --                 -- Resolving the terminal's inability to distinguish between `TAB` and `<C-i>` in normal mode
    --                 return "<C-i>"
    --             end
    --         end, { desc = "Accept Copilot NES suggestion", expr = true })
    --     end,
    -- },
    -- {
    --     "olimorris/codecompanion.nvim",
    --     dependencies = {
    --         "nvim-lua/plenary.nvim",
    --         "nvim-treesitter/nvim-treesitter",
    --         "nvim-telescope/telescope.nvim",
    --     },
    --     config = function()
    --         require("codecompanion").setup({
    --             -- Use Claude Code as your default background CLI agent
    --             interactions = {
    --                 cli = {
    --                     agent = "claude_code",
    --                     agents = {
    --                         claude_code = {
    --                             cmd = "claude", -- Requires `npm install -g @anthropic-ai/claude-code`
    --                             args = { "--acp" }, -- Starts Claude Code in Agent Client Protocol mode
    --                             provider = "terminal",
    --                         },
    --                     },
    --                 },
    --             },
    --             adapters = {
    --                 acp = {
    --                     claude_code = function()
    --                         return require("codecompanion.adapters").extend("claude_code", {
    --                             env = {
    --                                 CLAUDE_CODE_OAUTH_TOKEN = os.getenv("CLAUDE_CODE_OAUTH"),
    --                             },
    --                         })
    --                     end,
    --                 },
    --             },
    --             strategies = {
    --                 chat = {
    --                     adapter = "claude_code",
    --                 },
    --             },
    --         })
    --
    --         -- Multi-Session Keybindings
    --         vim.keymap.set({ "n", "v" }, "<leader>ai", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle Chat Session" })
    --         vim.keymap.set({ "n", "v" }, "<leader>an", "<cmd>CodeCompanionChat<cr>", { desc = "New Parallel Session" })
    --         vim.keymap.set("n", "<leader>as", "<cmd>CodeCompanionActions<cr>", { desc = "List/Search Active Sessions" })
    --     end,
    -- },
    {
        "coder/claudecode.nvim",
        dependencies = { "folke/snacks.nvim" },
        opts = {},
        config = function(_, opts)
            require("claudecode").setup(opts)
            wire_session_lifecycle()
        end,
        -- `cmd` lets lazy.nvim create command stubs that load the plugin on first use,
        -- so `:ClaudeCode` and friends work on a fresh start. Without it, a keys-only
        -- spec defers loading until a <leader>a* mapping is pressed and the commands
        -- would not exist yet.
        cmd = {
            "ClaudeCode",
            "ClaudeCodeSessions",
            "ClaudeCodeFocus",
            "ClaudeCodeSelectModel",
            "ClaudeCodeAdd",
            "ClaudeCodeSend",
            "ClaudeCodeTreeAdd",
            "ClaudeCodeStatus",
            "ClaudeCodeStart",
            "ClaudeCodeStop",
            "ClaudeCodeOpen",
            "ClaudeCodeClose",
            "ClaudeCodeDiffAccept",
            "ClaudeCodeDiffDeny",
            "ClaudeCodeCloseAllDiffs",
        },
        keys = {
            { "<leader>a", nil, desc = "AI/Claude Code" },
            -- ai shows and hides the pane; the conversation behind it runs in the
            -- daemon either way, so there is nothing to resume by hand. ar picks
            -- another one (telescope, "＋ new session" first) -- use it instead of
            -- `/resume`, which would re-purpose the session it runs in.
            { "<leader>ai", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
            { "<leader>ar", claude.pick, desc = "Pick a Claude session" },
            { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
            { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
            { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
            -- Diff management
            { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
            { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
        },
    }
}
