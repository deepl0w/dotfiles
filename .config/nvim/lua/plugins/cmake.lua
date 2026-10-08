-- cmake-tools.nvim: CMake integration. Also pulled in as a telescope dependency, and
-- lualine_cfg requires it directly.
--
-- Besides the setup, this spec defuses one upstream bug. cmake.register_autocmd()
-- installs a global TermClose handler that runs
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

local cmake_cfg = {
    cmake_build_directory = "bin/${variant:target}/${variant:buildType}",
    cmake_build_options = { "-j16" },
    cmake_variants_message = {
        short = { show = true },
        long = { show = false },
    },
    cmake_dap_configuration = { -- debug settings for cmake
        name = "cpp",
        type = "cppdbg",
        request = "launch",
        stopOnEntry = false,
        setupCommands = {
            {
                text = '-enable-pretty-printing',
                description = 'enable pretty printing',
                ignoreFailures = false
            },
        },
    },
    cmake_executor = {
        name = "quickfix",
        default_opts = {
            show = "only_on_error"
        },
    },
    cmake_runner = {
        name = "quickfix",
    },
}

return {
    {
        "Civitasv/cmake-tools.nvim",
        commit = "643e46b",
        config = function()
            local ok, cmake = pcall(require, "cmake-tools")
            if not ok then
                return
            end
            -- register_autocmd() runs on setup and again on every :CMakeSelectCwd /
            -- :CMakeSelectBuildDir, so wrap it: pruning once would only hold until
            -- the next call re-registered the broken handler. Upstream also keeps the
            -- id of the handler we deleted and deletes it again on the next call,
            -- which throws for an id that no longer exists -- so let that one
            -- deletion fail quietly instead of aborting the re-registration.
            local register = cmake.register_autocmd
            if type(register) == "function" then
                cmake.register_autocmd = function(...)
                    local del_autocmd = vim.api.nvim_del_autocmd
                    vim.api.nvim_del_autocmd = function(id)
                        pcall(del_autocmd, id)
                    end
                    local reg_ok, err = pcall(register, ...)
                    vim.api.nvim_del_autocmd = del_autocmd
                    fix_termclose_feedkeys()
                    if not reg_ok then
                        error(err, 0)
                    end
                end
            end

            -- setup() goes through the wrapped register_autocmd, which applies the fix
            cmake.setup(cmake_cfg)

            vim.keymap.set("n", "<F7>", function() vim.api.nvim_command("CMakeBuild") end, {})

            -- Re-setup so cmake-tools follows the project when a C/C++ buffer is shown
            -- from another cwd (project.nvim chdirs per tab); setup() reloads the
            -- session file and re-registers autocmds, so skip it when nothing moved.
            local setup_cwd = vim.fn.getcwd()
            vim.api.nvim_create_autocmd({ 'BufWinEnter' }, {
                pattern = { '*.cpp', '*.txx', '*.c', '*.h', '*.hpp' },
                callback = function()
                    local cwd = vim.fn.getcwd()
                    if cwd ~= setup_cwd then
                        setup_cwd = cwd
                        cmake.setup(cmake_cfg)
                    end
                end
            })
        end,
    },
}
