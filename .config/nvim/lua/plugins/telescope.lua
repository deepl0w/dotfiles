return {
    -- Telescope (for references, symbols, etc.)
    {
        "nvim-telescope/telescope-ui-select.nvim",
        config = function()
            require("telescope").load_extension("ui-select")
        end,
    },
    {
        "axkirillov/easypick.nvim",
        config = function()
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
        end,
    },
    {
        "nvim-telescope/telescope-dap.nvim",
        config = function()
            require("telescope").load_extension("dap")
        end,
        dependencies = { "mfussenegger/nvim-dap" },
    },
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
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "DrKJeff16/project.nvim", "Civitasv/cmake-tools.nvim" },
        cmd = "Telescope",
        config = function()
            local telescope = require('telescope')
            local builtin = require("telescope.builtin")

            require('telescope').load_extension('projects')
            require('telescope').load_extension('cmake_tools')

            telescope.setup({
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
                    }
            })

            local opts = { noremap = true, silent = true }

            vim.keymap.set("n", "<C-p>", builtin.find_files, opts)
            vim.keymap.set("n", "<C-g>", builtin.live_grep, opts)
            vim.keymap.set('n', '<space>b', builtin.buffers, opts)
            vim.keymap.set('n', '<C-c>', builtin.colorscheme, opts)

            vim.keymap.set("n", "gt", builtin.lsp_definitions, opts)
            vim.keymap.set("n", "gi", builtin.lsp_implementations, opts)
            vim.keymap.set("n", "gr", builtin.lsp_references, opts)
            vim.keymap.set("n", "<C-s>", builtin.lsp_workspace_symbols, opts)
            vim.keymap.set("n", "<C-t>", builtin.lsp_document_symbols, opts)

            vim.keymap.set('n', '<C-w>', telescope.extensions.projects.projects , opts)
            vim.keymap.set('i', '<C-w>', telescope.extensions.projects.projects , opts)
            vim.keymap.set('t', '<C-w>', telescope.extensions.projects.projects , opts)

        end,
    },
}
