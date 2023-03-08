local PKGS = {
    "savq/paq-nvim";            -- Let Paq Manage itself

    "nvim-lua/plenary.nvim";    -- Utility functions
    "nvim-lua/popup.nvim";      -- Popup API from vim to nvim

    "svermeulen/vimpeccable";   -- Lua API map keys

    "mfussenegger/nvim-dap";    -- Debug Adapter Protocol
    "rcarriga/nvim-dap-python";
    "rcarriga/nvim-dap-ui";
    "nvim-treesitter/nvim-treesitter";
    "theHamsta/nvim-dap-virtual-text";

    "nvim-telescope/telescope.nvim";  -- Fuzzy finder with nice ui
    "fannheyward/telescope-coc.nvim"; -- Integrate coc outputs in telescope
    "Shatur/neovim-tasks";            -- Build/Run tasks
    "ahmedkhalf/project.nvim";        -- Projects
}

-- Install packages package manager if not installed
require("bootstrap").bootstrap(PKGS)

vim.cmd "packadd paq-nvim"
require("paq")(PKGS)

local Path = require('plenary.path')
local Scan = require('plenary.scandir')

------------------------------
-- Telescope
-----------------------------path-
require('telescope').setup{
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
  },
  pickers = {
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
  },
  extensions = {
    coc = {
        prefer_location = true
    }
  }
}
require('telescope').load_extension('coc')
require('telescope').load_extension('projects')

local telescope = require('telescope')
local telescope_builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', telescope_builtin.find_files, {})
vim.keymap.set('n', '<C-g>', telescope_builtin.live_grep, {})
vim.keymap.set('n', '<C-w>', require('telescope').extensions.projects.projects , {})
vim.keymap.set('i', '<C-w>', require('telescope').extensions.projects.projects , {})
vim.keymap.set('t', '<C-w>', require('telescope').extensions.projects.projects , {})
--vim.keymap.set('n', '<C-s>', require('telescope').extensions.coc.workspace_symbols , {})

vim.keymap.set('n', '<A-h>', '<C-w>h')
vim.keymap.set('n', '<A-j>', '<C-w>j')
vim.keymap.set('n', '<A-k>', '<C-w>k')
vim.keymap.set('n', '<A-l>', '<C-w>l')

vim.keymap.set('t', '<A-h>', '<C-\\><C-n><C-w>h')
vim.keymap.set('t', '<A-j>', '<C-\\><C-n><C-w>j')
vim.keymap.set('t', '<A-k>', '<C-\\><C-n><C-w>k')
vim.keymap.set('t', '<A-l>', '<C-\\><C-n><C-w>l')

------------------------------
-- DAP
------------------------------
local dap = require("dap")
local dapui = require("dapui")
require("dapui").setup()
require("nvim-dap-virtual-text").setup()
require('dap-python').setup('~/.virtualenvs/debugpy/bin/python')

local function vscode_debugger_path()
    p = Path:new(Path.path.home)
    vscode_dir = Scan.scan_dir(tostring(p), {depth = 1, hidden = true, add_dirs = true, search_pattern = "%.vscode"})
    p = Path:new(vscode_dir[1], 'extensions')

    cpptools_dir = Scan.scan_dir(tostring(p), {depth = 1, hidden = true, add_dirs = true, search_pattern = 'ms%-vscode%.cpptools'})
    p = Path:new(cpptools_dir[1], 'debugAdapters', 'bin', 'OpenDebugAD7')

    return p
end

dap.adapters.cppdbg = {
    id = 'cppdbg',
    type = "executable",
    command = tostring(vscode_debugger_path())
}

dap.configurations.python = {
    {
        type = 'python',
        request = 'launch',
        name = 'Launch file',
        program = '${file}',
        pythonPath = function()
            return '/usr/bin/python'
        end
    }
}

dap.configurations.cpp = {
  {
    name = "Launch file",
    type = "cppdbg",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopAtEntry = true,

    setupCommands = {
      {
         text = '-enable-pretty-printing',
         description =  'enable pretty printing',
         ignoreFailures = false
      },
    },
  },
  {
    name = 'Attach to gdbserver :1234',
    type = 'cppdbg',
    request = 'launch',
    MIMode = 'gdb',
    miDebuggerServerAddress = 'localhost:1234',
    miDebuggerPath = '/usr/bin/gdb',
    cwd = '${workspaceFolder}',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
  },
}

vim.fn.sign_define('DapBreakpoint', {text='🛑', texthl='', linehl='', numhl=''})

-- wrapper to load launch.json if it exists when starting debug
local function dap_continue_with_launchjs()
    if not dap.session() then
        require('dap.ext.vscode').load_launchjs(nil, { cppdbg = {'c', 'cpp'} })
    end
    dap.continue()
end

vim.keymap.set("n", "<F5>",       dap_continue_with_launchjs)
vim.keymap.set("n", "<F10>",      dap.step_over)
vim.keymap.set("n", "<F11>",      dap.step_into)
vim.keymap.set("n", "<F12>",      dap.step_out)
vim.keymap.set("n", "<F8>",       dap.toggle_breakpoint)
vim.keymap.set("n", "<leader>dr", dap.repl.toggle)
vim.keymap.set("n", "<leader>dl", dap.run_last)
vim.keymap.set("n", "<leader>du", dapui.toggle)


dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
end

------------------------------
-- Tasks
------------------------------
require('tasks').setup({
  default_params = {
    cmake = {
      cmd = 'cmake',
      build_dir = tostring(Path:new('{cwd}', 'bin')),
      build_type = 'Debug',
      dap_name = 'cppdbg',
      args = {
        configure = { '-D', 'CMAKE_EXPORT_COMPILE_COMMANDS=1' },
      },
    },
  },
  save_before_run = true, -- If true, all files will be saved before executing a task.
  params_file = 'neovim.json', -- JSON file to store module and task parameters.
  quickfix = {
    pos = 'botright', -- Default quickfix position.
    height = 12, -- Default height.
  },
  dap_open_command = function() return require('dap').repl.open() end,
})

require("project_nvim").setup({
    scope_chdir = 'tab'
})
