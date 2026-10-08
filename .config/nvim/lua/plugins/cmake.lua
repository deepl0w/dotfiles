-- cmake-tools.nvim arrives as a telescope dependency (and lualine_cfg requires it
-- directly); this spec exists only to defuse one upstream bug.
--
-- cmake.register_autocmd() installs a global TermClose handler that runs
--     vim.cmd.stopinsert()
--     vim.api.nvim_feedkeys("<C-\\><C-n><CR>", "n", false)
-- and that second line never goes through nvim_replace_termcodes, so the keys are
-- fed as those literal characters -- typed into whatever window has focus when ANY
-- terminal job exits anywhere in Neovim. A telescope preview that runs a command,
-- a Claude pane whose client exits: the text lands in the prompt you were using.
--
-- The stopinsert is the part that was meant to matter (leave terminal mode once a
-- build finishes so its output can be scrolled), so keep that, scope it to cmake's
-- own terminal, and drop the feedkeys.
local function fix_termclose_feedkeys()
    local ok, autocmds = pcall(vim.api.nvim_get_autocmds, { event = "TermClose", group = "cmaketools" })
    if not ok then
        return
    end
    for _, autocmd in ipairs(autocmds) do
        pcall(vim.api.nvim_del_autocmd, autocmd.id)
    end
    vim.api.nvim_create_autocmd("TermClose", {
        group = vim.api.nvim_create_augroup("cmaketools_termclose_fix", { clear = true }),
        callback = function(args)
            local name = vim.api.nvim_buf_get_name(args.buf):lower()
            if name:find("cmake", 1, true) then
                vim.cmd.stopinsert()
            end
        end,
    })
end

return {
    {
        "Civitasv/cmake-tools.nvim",
        config = function()
            local ok, cmake = pcall(require, "cmake-tools")
            if not ok then
                return
            end
            -- register_autocmd() runs again on setup and on every :CMakeSelectCwd /
            -- :CMakeSelectBuildDir, so wrap it: pruning once would only hold until
            -- the next call re-registered the broken handler.
            local register = cmake.register_autocmd
            if type(register) == "function" then
                cmake.register_autocmd = function(...)
                    register(...)
                    fix_termclose_feedkeys()
                end
            end
            fix_termclose_feedkeys()
        end,
    },
}
