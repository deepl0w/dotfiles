local PKGS = {
    "nvim-lua/plenary.nvim",    -- Utility functions
    "nvim-lua/popup.nvim",      -- Popup API from vim to nvim
    "svermeulen/vimpeccable",   -- Lua API map keys
    "nvim-treesitter/nvim-treesitter",  -- parser

    "mfussenegger/nvim-dap",    -- Debug Adapter Protocol
    "rcarriga/nvim-dap-python",
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "alfaix/neotest-gtest"
        }
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "nvim-neotest/nvim-nio"
        }

    },
    "theHamsta/nvim-dap-virtual-text",

    "nvim-telescope/telescope.nvim",  -- Fuzzy finder with nice ui
    "nvim-telescope/telescope-ui-select.nvim",
    "axkirillov/easypick.nvim",       -- Easy telescope pickers
    "fannheyward/telescope-coc.nvim", -- Integrate coc outputs in telescope
    "nvim-telescope/telescope-dap.nvim", -- Integrate coc outputs in telescope
    "Shatur/neovim-tasks",            -- Build/Run tasks
    {
        "Civitasv/cmake-tools.nvim",      -- CMake integration
        commit = "643e46b"
    },
    "stevearc/overseer.nvim",
    "ahmedkhalf/project.nvim",        -- Projects
    "smoka7/hop.nvim",                -- better easymotion
    { 'chaoren/vim-wordmotion', event = 'VeryLazy' },
    "folke/noice.nvim",               -- floating windows Ufolke/noice.nvim
    "MunifTanjim/nui.nvim",           -- UI component lib
    "rcarriga/nvim-notify",           -- fancy notification manager
    "kylechui/nvim-surround",         -- surround fommand for different brackets

    "akinsho/bufferline.nvim",        -- buffer line
    "nvim-tree/nvim-web-devicons",    -- dev icons
    "lewis6991/gitsigns.nvim",        -- git signs
    {
        "aaronhallaert/advanced-git-search.nvim",
        config = function()
            require("telescope").load_extension("advanced_git_search")
        end,
        dependencies = {
            "tpope/vim-fugitive",
            "tpope/vim-rhubarb",
        },
    },
    {
        'tanvirtin/vgit.nvim', branch = 'v1.0.x',
        -- or               , tag = 'v1.0.2',
        dependencies = { 'nvim-lua/plenary.nvim', 'nvim-tree/nvim-web-devicons' },
        -- Lazy loading on 'VimEnter' event is necessary.
        event = 'VimEnter',
        config = function() require("vgit").setup({
                keymaps = {
                    ['n <leader>gs'] = function() require('vgit').buffer_hunk_stage() end,
                    ['n <leader>gr'] = function() require('vgit').buffer_hunk_reset() end,
                    ['n <leader>gp'] = function() require('vgit').buffer_hunk_preview() end,
                    ['n <leader>gb'] = function() require('vgit').buffer_blame_preview() end,
                    ['n <leader>gf'] = function() require('vgit').buffer_diff_preview() end,
                    ['n <leader>gh'] = function() require('vgit').buffer_history_preview() end,
                    ['n <leader>gu'] = function() require('vgit').buffer_reset() end,
                    ['n <leader>gd'] = function() require('vgit').project_diff_preview() end,
                    ['n <leader>gx'] = function() require('vgit').toggle_diff_preference() end,
                },
        }
        ) end,
    },

    "ellisonleao/gruvbox.nvim",       -- gruvbox color scheme
    "rebelot/kanagawa.nvim",          -- kanagawa colorscheme

    "xolox/vim-misc",                 -- auto-load vim scripts
    "ncm2/float-preview.nvim",        -- preview in floating window
    "sindrets/diffview.nvim",         -- Diff integration
    "ku1ik/vim-pasta",
    {
        "numToStr/Comment.nvim",          -- commenting plugin
        opts = {
            toggler = {
                line = '<leader>cc',
                block = nil
            },
            opleader = {
                line = '<leader>c',
                block = nil
            },
            mappings = {
                basic = true,
                extra = true
            }
        },
        lazy = false,
    },
    {
        "tpope/vim-fugitive",
        lazy = true,
        cmd = {"Git", "Gdiffsplit"}
    },
    {
        "akinsho/toggleterm.nvim",
        version = '*',
        opts = { open_mapping = [[<c-\>]], direction = 'float' },
        keys = [[<c-\>]],
    },
    {
        "neoclide/coc.nvim",
        branch = 'release',
        init = function()
            vim.g.coc_global_extensions = {
                'coc-json', 'coc-git', 'coc-kotlin', 'coc-pyright', 'coc-lists', 'coc-highlight', 'coc-markdownlint',
                'coc-vimlsp', 'coc-diagnostic', 'coc-lightbulb', 'coc-cmake', 'coc-sumneko-lua', 'coc-clangd', "@hexuhua/coc-copilot"
            }
        end,
    },
    "nvim-lualine/lualine.nvim",      -- status line
    {
        'fei6409/log-highlight.nvim',  -- log highlights
        config = function()
            require('log-highlight').setup {
                extension = 'log',
                filename = {
                    'mesasges',
                },
                pattern = {
                    '/var/log/.*',
                    'messages%..*',
                    '.*Log.txt',
                },
            }
        end,
    },
    {
      'stevearc/oil.nvim',
      ---@module 'oil'
      ---@type oil.SetupOpts
      opts = {},
      dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    {
        "Funk66/jira.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
          require("jira").setup()
        end,
        cond = function()
          return vim.env.JIRA_API_TOKEN ~= nil
        end,
        keys = {
          { "<leader><leader>jv", ":JiraView<cr>", desc = "View Jira issue", silent = true },
          { "<leader><leader>jo", ":JiraOpen<cr>", desc = "Open Jira issue in browser", silent = true },
        }
    },
    {
      "zbirenbaum/copilot.lua",
      cmd = "Copilot",
      event = "InsertEnter",
      config = function()
        require("copilot").setup({})
      end,
    },
    {
    "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
          { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
          { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
        },
        build = "make tiktoken", -- Only on MacOS or Linux
        opts = {
            chat_autocomplete = false
        },
        -- See Commands section for default commands if you want to lazy load on them
    },
}

-- Install packages and package manager if not installed
require("bootstrap").bootstrap(PKGS)

local Path = require('plenary.path')
local Scan = require('plenary.scandir')

local utils = require('utils')
local icons = require("icons")
local llcfg = require('lualine_cfg')

utils.persistent_undo()

require("nvim-surround").setup()

------------------------------
-- Lualine
------------------------------

require('lualine').setup {
    options = {
        globalstatus = true,
    },
    sections = {
        lualine_c = {
            'filename',
            llcfg.cmake_preset,
            llcfg.cmake_type,
            llcfg.cmake_kit,
            llcfg.cmake_build,
            llcfg.cmake_build_preset,
            llcfg.cmake_build_target,
            llcfg.cmake_debug
        },
        lualine_x = {
            llcfg.macro,
            'encoding',
            'fileformat',
            'filetype'
        },
    }
}

------------------------------
-- Oil
------------------------------
require("oil").setup()

------------------------------
-- Treesitter
------------------------------

require('nvim-treesitter.configs').setup {
    ensure_installed = { 'c', 'cpp', 'lua', 'vim', 'bash', 'python', 'rust', 'regex', 'markdown', 'markdown_inline' },
    sync_install = false,
    auto_install = true,

    highlight = {
        enable = true
    },
    additional_vim_regex_highlighting = false
}

------------------------------
--  Neotest
------------------------------

local neotest = require("neotest")
neotest.setup({
  adapters = {
    require("neotest-gtest").setup({
        debug_adapter = "cppdbg",

        is_test_file = function(file)
            local p = Path:new(file)
            local test_path = file:match('/utest/') or file:match('/itest/') or file:match('/apitest/')
            local is_cpp = file:match('.cpp$')

            return is_cpp and test_path
        end
    })
  }
})
vim.keymap.set('n', ',nt', neotest.summary.toggle, {})

------------------------------
-- Telescope
------------------------------
require('telescope').setup {
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
        n = {
            ['<c-d>'] = require('telescope.actions').delete_buffer
        },
        i = {
            ['<c-d>'] = require('telescope.actions').delete_buffer
        },
    },
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
require('telescope').load_extension('dap')
require('telescope').load_extension('projects')
require('telescope').load_extension('cmake_tools')
require('telescope').load_extension('ui-select')

local easypick = require("easypick")
easypick.setup({
    pickers = {
        {
            name = "ls",
            command = "ls",
            previewer = easypick.previewers.default(),
            action = easypick.actions.nvim_commandf("~/.config/nvim/cmake_build.py %s")
        },
    }
})

local telescope = require('telescope')
local telescope_builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', telescope_builtin.find_files, {})
vim.keymap.set('n', '<C-g>', telescope_builtin.live_grep, {})
vim.keymap.set('n', '<C-c>', telescope_builtin.colorscheme, {})
vim.keymap.set('n', '<C-w>', telescope.extensions.projects.projects , {})
vim.keymap.set('i', '<C-w>', telescope.extensions.projects.projects , {})
vim.keymap.set('t', '<C-w>', telescope.extensions.projects.projects , {})
vim.keymap.set('n', '<C-s>', function () vim.api.nvim_command('Telescope coc workspace_symbols') end , {})
vim.keymap.set('n', '<C-t>', function () vim.api.nvim_command('Telescope coc document_symbols') end , {})
vim.keymap.set('n', 'gt', function () vim.api.nvim_command('Telescope coc definitions') end , {})
vim.keymap.set('n', 'gi', function () vim.api.nvim_command('Telescope coc implementations') end , {})
vim.keymap.set('n', 'gr', function () vim.api.nvim_command('Telescope coc references') end , {})
vim.keymap.set('n', '<space>a', function () vim.api.nvim_command('Telescope coc diagnostics') end, { silent = true })
vim.keymap.set('n', '<space>A', function () vim.api.nvim_command('Telescope coc workspace_diagnostics') end, { silent = true })
vim.keymap.set('n', '<space>c', function () vim.api.nvim_command('Telescope coc commands') end, { silent = true })
vim.keymap.set('n', '<space>b', function () vim.api.nvim_command('Telescope buffers') end, { silent = true })

------------------------------
-- Coc
------------------------------

vim.keymap.set('n', '<leader>rn', '<plug>(coc-rename)', {})
vim.keymap.set('n', '<leader><leader>f', '<plug>(coc-format-selected)', {})
vim.keymap.set('x', '<leader><leader>f', '<plug>(coc-format-selected)', {})
vim.keymap.set('n', '<leader>x', '<plug>(coc-codeaction-cursor)', {})
vim.keymap.set('x', '<leader>x', '<plug>(coc-codeaction-cursor)', {})
vim.keymap.set('n', '<tab>', '<plug>(coc-range-select)', { silent = true })
vim.keymap.set('x', '<tab>', '<plug>(coc-range-select)', { silent = true })
vim.keymap.set('x', '<s-tab>', '<plug>(coc-range-select-backword)', { silent = true })
vim.keymap.set('n', '<leader>ih', function () vim.api.nvim_command('CocCommand document.toggleInlayHint') end, { silent = true, expr = true })
vim.keymap.set('i', '<c-l>', function () vim.fn["coc#refresh"]() end, { silent = true })

------------------------------
-- Coc
------------------------------
vim.keymap.set('n', '<leader>dv', function() vim.api.nvim_command('DiffviewOpen') end, {})
vim.keymap.set('n', '<leader>df', function() vim.api.nvim_command('DiffviewFileHistory % --no-merges') end, {})

------------------------------
-- General maps
------------------------------

-- toggle color column
vim.keymap.set('', '<A-c>', function()
    if (vim.wo.colorcolumn ~= '0') then
        vim.wo.colorcolumn = '0'
    else
        vim.wo.colorcolumn = '120'
    end
end)

-- treat long lines as multiple lines
vim.keymap.set('', 'j', 'gj')
vim.keymap.set('', 'k', 'gk')

vim.keymap.set('n', ';', ':')

vim.keymap.set('n', '<leader>d', '"_d')
vim.keymap.set('v', '<leader>d', '"_d')
vim.keymap.set('v', 'p', '"_dP')

vim.keymap.set('n', '<A-h>', '<C-w>h')
vim.keymap.set('n', '<A-j>', '<C-w>j')
vim.keymap.set('n', '<A-k>', '<C-w>k')
vim.keymap.set('n', '<A-l>', '<C-w>l')

vim.keymap.set("t", "<esc>", "<C-\\><C-n>")
vim.keymap.set('t', '<A-h>', '<C-\\><C-n><C-w>h')
vim.keymap.set('t', '<A-j>', '<C-\\><C-n><C-w>j')
vim.keymap.set('t', '<A-k>', '<C-\\><C-n><C-w>k')
vim.keymap.set('t', '<A-l>', '<C-\\><C-n><C-w>l')

vim.keymap.set('n', '<C-j>', 'gT')
vim.keymap.set('n', '<C-k>', 'gt')

vim.keymap.set('t', '<C-j>', '<C-\\><C-n>gT')
vim.keymap.set('t', '<C-k>', '<C-\\><C-n>gt')

vim.keymap.set('n', '<A-i>', function()
    vim.api.nvim_command("execute 'silent! tabmove ' . (tabpagenr() - 2)")
end)

vim.keymap.set('n', '<A-o>', function()
    vim.api.nvim_command("execute 'silent! tabmove ' . (tabpagenr() + 1)")
end)

vim.keymap.set('n', '<space>', 'za')

vim.keymap.set('n', 'K', utils.show_documentation)

-- Resize
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", { silent = true, desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", { silent = true, desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", ":vertical :resize -2<CR>", { silent = true, desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", ":vertical :resize +2<CR>", { silent = true, desc = "Increase window width" })

-- HOP
------------------------------
local hop = require('hop')
local directions = require('hop.hint').HintDirection

vim.keymap.set('', '<leader>w', function()
  hop.hint_words({ direction = directions.AFTER_CURSOR })
end, { remap = true })

vim.keymap.set('', '<leader>b', function()
  hop.hint_words({ direction = directions.BEFORE_CURSOR })
end, { remap = true })

vim.keymap.set('', '<leader>j', function()
  hop.hint_lines({ direction = directions.AFTER_CURSOR })
end, { remap = true })

vim.keymap.set('', '<leader>k', function()
  hop.hint_lines({ direction = directions.BEFORE_CURSOR })
end, { remap = true })

vim.keymap.set('', '<leader>f', function()
  hop.hint_char1()
end, { remap = true })

vim.keymap.set('', '<leader>t', function()
  hop.hint_patterns()
end, { remap = true })

hop.setup {
    keys = 'asdfjklghvncmxturiewo'
}

------------------------------
-- DAP
------------------------------
local dap = require("dap")
local dapui = require("dapui")
require("dapui").setup()
require("nvim-dap-virtual-text").setup()
require('dap-python').setup('~/.virtualenvs/debugpy/bin/python')

local function vscode_debugger_path()
    local p = Path:new(Path.path.home)
    local vscode_dir = Scan.scan_dir(tostring(p), {depth = 1, hidden = true, add_dirs = true, search_pattern = "%.vscode"})
    p = Path:new(vscode_dir[#vscode_dir], 'extensions')

    local cpptools_dir = Scan.scan_dir(tostring(p), {depth = 1, hidden = true, add_dirs = true, search_pattern = 'ms%-vscode%.cpptools'})
    p = Path:new(cpptools_dir[1], 'debugAdapters', 'bin', 'OpenDebugAD7')

    return p
end

dap.adapters.cppdbg = {
    id = "cppdbg",
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
      return vim.fn.input({'Path to executable: ', vim.fn.getcwd() .. '/', 'file'})
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
}

vim.fn.sign_define('DapBreakpoint', {text=icons.ui.BigCircle, texthl='', linehl='', numhl=''})

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
vim.keymap.set("n", "<space>k",   dapui.eval)
vim.keymap.set("v", "<space>k",   dapui.eval)


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
-- CMake Tools
------------------------------
require('overseer').setup()
local cmake = require("cmake-tools")
local cmake_cfg = {
    cmake_build_directory = "bin/${variant:target}/${variant:buildType}",
    cmake_build_options = {"-j16"},
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
                description =  'enable pretty printing',
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
cmake.setup(cmake_cfg)

vim.keymap.set("n", "<F7>", function() vim.api.nvim_command("CMakeBuild") end, {})

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
    scope_chdir = 'tab',
    patterns = { ".project_root", ">work_git", ">git", "package.json" },
})

------------------------------
-- noice
------------------------------

require("noice").setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
  },
  -- you can enable a preset for easier configuration
  presets = {
    command_palette = true,         -- position the cmdline and popupmenu together
    long_message_to_split = true,   -- long messages will be sent to a split
    inc_rename = false,             -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false,         -- add a border to hover docs and signature help
  },
})

------------------------------
-- UI
------------------------------
vim.o.termguicolors = true

require'nvim-web-devicons'.setup()
require('gitsigns').setup()

require("gruvbox").setup {
    contrast = "medium"
}
require('kanagawa').setup {
    compile = true,
    dimInactive = true
}
vim.api.nvim_command("colorscheme kanagawa")

vim.o.cursorline = true
vim.o.report = 1
vim.o.number = false

vim.opt.wildmenu = true
vim.opt.wildmode = "list:longest,full"

-- ignore compiled files and executables
vim.opt.wildignore = {"*.obj", "*.o", "*~", "*.pyc", "*.out", "*.exe"}
if vim.fn.has("win16") or vim.fn.has("win32") then
    table.insert(vim.opt.wildignore, ".git\\*")
    table.insert(vim.opt.wildignore, ",.hg\\*")
    table.insert(vim.opt.wildignore, ".svn\\*")
else
    table.insert(vim.opt.wildignore, "*/.git/*")
    table.insert(vim.opt.wildignore, "*/.hg/*")
    table.insert(vim.opt.wildignore, "*/.svn/*")
    table.insert(vim.opt.wildignore, "*/.DS_Store")
end

vim.opt.fillchars = vim.opt.fillchars + { vert = '|' }
vim.opt.shortmess = vim.opt.shortmess + 'I'

require('bufferline').setup {
    options = {
        mode = "tabs",
        separator_style = "slope",
        tab_size = 20,
    }
}

------------------------------
-- General
------------------------------
vim.o.history = 1000
vim.o.mouse = 'a'
vim.o.ttimeoutlen = 0
vim.o.timeoutlen = 500
vim.o.updatetime = 300
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.exrc = true
vim.o.secure = true

-- folds and tabs
vim.o.foldlevelstart = 9
--vim.o.foldmethod = 'expr'
--vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.foldmethod = 'manual'
vim.o.foldexpr = '0'
vim.o.foldenable = false

vim.o.shiftwidth = 4
vim.o.smarttab = true
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.expandtab = true
vim.o.list = true
vim.opt.listchars['tab'] = '»'

-- text editing and searching
vim.o.smartcase = true
vim.o.ignorecase = true
vim.o.incsearch = true
vim.o.icm = 'nosplit'
vim.o.showmatch = true
vim.o.matchtime = 2
vim.o.backspace = [[eol,start,indent]]

-- cursor always in the center
vim.o.scrolloff = 999

vim.api.nvim_create_user_command('Wipeout', function() utils.wipeout() end, { nargs = 0 })

-- Set clipboard to system clipboard
vim.opt.clipboard='unnamedplus'
if utils.is_wsl() then
    vim.g.clipboard = {
        name ='win32yank-wsl',
        copy = {
            ['+'] = 'win32yank.exe -i --crlf',
            ['*'] = 'win32yank.exe -i --crlf',
        },
        paste = {
            ['+'] = 'win32yank.exe -o --lf',
            ['*'] = 'win32yank.exe -o --lf',
        },
        cache_enabled = 0,
    }
end

------------------------------
-- Autocmd
------------------------------

-- Text editing and searching behavior
vim.api.nvim_create_autocmd({'BufNewFile','BufRead'}, {
        pattern = '*',
        callback = function()
            vim.opt_local.textwidth = 0
            vim.opt_local.formatoptions = 'tcrqnj'
        end
})

-- Language specific
vim.api.nvim_create_autocmd({'BufNewFile','BufRead'}, {
        pattern = {'*.txx', '*.ver'},
        callback = function()
            vim.opt_local.filetype = 'cpp'
        end
})

vim.api.nvim_create_autocmd({'BufWinEnter'}, {
        pattern = {'*.cpp', '*.txx', '*.c', '*.h', '*.hpp'},
        callback = function()
            cmake.setup(cmake_cfg)
        end
})

-- Delete trailing whitespaces at write
vim.api.nvim_create_autocmd({'BufWritePre'}, {
        pattern = '*',
        command = '%s/\\s\\+$//e'
})

vim.api.nvim_create_autocmd({'BufEnter'}, {
        pattern = '*',
        callback = function()
            if vim.bo.buftype == "terminal" then
                vim.cmd.startinsert()
                vim.opt_local.number = false
                vim.opt_local.scrolloff = 0
            else
                vim.opt_local.scrolloff = 8
            end
        end
})

------------------------------
-- Log highlight
------------------------------
-- nvim.api.nvim_command("au Syntax log syn keyword logLvError Error")
-- nvim.api.nvim_command("au Syntax log syn keyword logLvInfo Info")

vim.api.nvim_create_autocmd({'BufNewFile','BufRead'}, {
        pattern = '*Log.txt',
        callback = function()
            vim.api.nvim_command("syn keyword logLvError Error")
            vim.api.nvim_command("syn keyword logLvWarning Warning")
            vim.api.nvim_command("syn keyword logLvInfo Info")
            vim.api.nvim_command("syn keyword logLvDebug Debug")
            vim.api.nvim_command("syn keyword logLvTrace Verbose")
            vim.api.nvim_command("syn keyword logLvFatal Fatal")
        end
})
