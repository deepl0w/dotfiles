local PKGS = {
    "savq/paq-nvim";            -- Let Paq Manage itself

    "nvim-lua/plenary.nvim";    -- Utility functions
    "nvim-lua/popup.nvim";      -- Popup API from vim to nvim

    "svermeulen/vimpeccable";   -- Lua API map keys

    "mfussenegger/nvim-dap";    -- Debug Adapter Protocol
    "rcarriga/nvim-dap-ui";
    "nvim-treesitter/nvim-treesitter";
    "theHamsta/nvim-dap-virtual-text";

    "nvim-telescope/telescope.nvim";  -- Fuzzy finder with nice ui
    "fannheyward/telescope-coc.nvim"; -- Integrate coc outputs in telescope
    "Shatur/neovim-tasks";            -- Build/Run tasks
}

-- Install packages package manager if not installed
require("bootstrap").bootstrap(PKGS)

vim.cmd "packadd paq-nvim"
require("paq")(PKGS)

local Path = require('plenary.path')

------------------------------
-- Telescope
------------------------------
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

local telescope = require('telescope')
local telescope_builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', telescope_builtin.find_files, {})
--vim.keymap.set('n', '<C-s>', telescope.extensions.coc.workspace_symbols , {})

------------------------------
-- DAP
------------------------------
local dap = require("dap")
local dapui = require("dapui")
require("dapui").setup()

dap.adapters.cppdbg = {
    id = 'cppdbg',
    type = "executable",
    command = tostring(Path:new(Path.path.home, '.vscode/extensions/ms-vscode.cpptools-1.12.4-linux-x64/debugAdapters/bin/OpenDebugAD7'))
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

require("nvim-dap-virtual-text").setup()

vim.keymap.set("n", "<F5>",       dap.continue)
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
