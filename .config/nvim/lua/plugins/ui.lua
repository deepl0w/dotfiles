vim.o.termguicolors = true

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

return {
    -- Popup API from vim to nvim
    "nvim-lua/popup.nvim",
    -- floating windows Ufolke/noice.nvim
    {
        "folke/noice.nvim",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        config = function()
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
        end
    },
    -- UI component lib
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require('gitsigns').setup()
        end
    },
    {
        "nvim-tree/nvim-web-devicons",
        config = function()
            require('nvim-web-devicons').setup()
        end
    },
    {
        "rebelot/kanagawa.nvim",
        config = function()
            require('kanagawa').setup {
                dimInactive = true,
                transparent = false,
                theme = "wave"
            }
            vim.api.nvim_command("colorscheme kanagawa")
        end
    },
    "xiyaowong/transparent.nvim",
    {
        "nvim-lualine/lualine.nvim",
        config = function()
            local llcfg = require('lualine_cfg')
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

        end
    },
    {
        'fei6409/log-highlight.nvim',
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
        "akinsho/bufferline.nvim",
        config = function()
            require('bufferline').setup {
                options = {
                    mode = "tabs",
                    separator_style = "slope",
                    tab_size = 20,
                    show_buffer_close_icons = false,
                    show_close_icon = false,
                },
            }
        end
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { "markdown", "Avante", "codecompanion" },
      },
      ft = { "markdown", "Avante", "codecompanion" },
    },
}
