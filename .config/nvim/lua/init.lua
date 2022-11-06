local PKGS = {
    "savq/paq-nvim";            -- Let Paq Manage itself

    "nvim-lua/plenary.nvim";    -- Utility functions
    "nvim-lua/popup.nvim";      -- Popup API from vim to nvim

    "svermeulen/vimpeccable";   -- Lua API map keys

    "mfussenegger/nvim-dap";    -- Debug Adapter Protocol
    "rcarriga/nvim-dap-ui";
    "nvim-treesitter/nvim-treesitter";
    "theHamsta/nvim-dap-virtual-text";

    "nvim-telescope/telescope.nvim"; -- Fuzzy finder with nice ui
    "fannheyward/telescope-coc.nvim"; -- Integrate coc outputs in telescope
}

-- Install packages package manager if not installed
require("bootstrap").bootstrap(PKGS)

vim.cmd "packadd paq-nvim"
require("paq")(PKGS)

--local vimp = require('vimp')

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
--require("dapui").setup()
--require("dap").adapters.cppdbg = {
    --type = "executable",
    --command = "/usr/bin/lldb",
    --name = "lldb"
--}
--require('dap.ext.vscode').load_launchjs(nil, { cppdbg = {'c', 'cpp'} })
--require("nvim-dap-virtual-text").setup()

--vimp.nnoremap("<silent> <F5>",       "<Cmd>lua require'dap'.continue()<CR>")
--vimp.nnoremap("<silent> <F10>",      "<Cmd>lua require'dap'.step_over()<CR>")
--vimp.nnoremap("<silent> <F11>",      "<Cmd>lua require'dap'.step_into()<CR>")
--vimp.nnoremap("<silent> <F12>",      "<Cmd>lua require'dap'.step_out()<CR>")
--vimp.nnoremap("<silent> <F8>",       "<Cmd>lua require'dap'.toggle_breakpoint()<CR>")
--vimp.nnoremap("<silent> <Leader>dr", "<Cmd>lua require'dap'.repl.open()<CR>")
--vimp.nnoremap("<silent> <Leader>dl", "<Cmd>lua require'dap'.run_last()<CR>")
