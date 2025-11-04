-- Don't load LSP plugins when running inside VSCode
if vim.g.vscode then
    return {}
end

return {
    {
        "mason-org/mason.nvim",
        config = function()
            require("mason").setup()

        end,
    },
    {
        "mason-org/mason-lspconfig.nvim",
        opts = {},
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
        },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "clangd", "pyright", "lua_ls" },
            })
        end,
    },
    {
        "folke/neodev.nvim",
        config = function()
            require("neodev").setup({
              library = { plugins = true, types = true },
            })
        end,
    },
    -- Completion engine
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-cmdline",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "onsails/lspkind.nvim",
            "zbirenbaum/copilot-cmp",  -- Copilot source for nvim-cmp
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            local lspkind = require("lspkind")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                performance = {
                    debounce = 60,              -- Delay before showing completion (ms)
                    throttle = 30,              -- Delay between completion updates (ms)
                    fetching_timeout = 200,     -- Timeout for fetching completions
                    max_view_entries = 50,      -- Limit completion items shown
                },
                completion = {
                    autocomplete = {
                        require('cmp.types').cmp.TriggerEvent.TextChanged,
                    },
                    completeopt = 'menu,menuone,noinsert',
                },
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.confirm({ select = true })
                        else
                            fallback()  -- insert a normal newline
                        end
                    end, { "i", "s" }),
                    ["<Tab>"] = cmp.mapping.select_next_item(),
                    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                }),
                sources = cmp.config.sources({
                    { name = "copilot", max_item_count = 3 },  -- Limit Copilot suggestions
                    { name = "nvim_lsp", max_item_count = 20 },
                    { name = "luasnip", max_item_count = 5 },
                    { name = "buffer", max_item_count = 5 },
                    { name = "path", max_item_count = 5 },
                }),
                formatting = {
                    format = function(entry, vim_item)
                        if entry.source.name == "copilot" then
                            vim_item.kind = "  Copilot"
                            vim_item.kind_hl_group = "CmpItemKindCopilot"
                        end
                        return lspkind.cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)
                    end,
                },
            })

            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            vim.lsp.config("clangd", {
                cmd = {
                    "clangd",
                    "--background-index",           -- Index in background for better perf
                    "--clang-tidy=false",           -- Disable clang-tidy for performance (enable manually if needed)
                    "--completion-style=detailed",
                    "--header-insertion=iwyu",
                    "--pch-storage=memory",         -- Store PCH in memory for speed
                    "--log=error",                  -- Reduce logging overhead
                    "--j=4",                        -- Use 4 threads for background work
                    "--limit-results=20",           -- Limit completion results
                },
                filetypes = { "c", "cpp", "objc", "objcpp" },
                root_dir = vim.fs.dirname(vim.fs.find({ ".git", "compile_commands.json" }, { upward = true })[1] or vim.loop.cwd()),
                capabilities = capabilities,
                -- Add debouncing to reduce frequent updates
                flags = {
                    debounce_text_changes = 200,  -- Increased debounce for smoother typing
                },
            })

            vim.lsp.config("pyright", {
                cmd = { "pyright-langserver", "--stdio" },
                filetypes = { "python" },
                capabilities = capabilities,
                flags = {
                    debounce_text_changes = 200,  -- Increased debounce for smoother typing
                },
            })
            vim.lsp.config("vimls", {
                cmd = { "vim-language-server", "--stdio" },
                filetypes = { "vim" },
                root_dir = vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true })[1] or vim.loop.cwd()),
                capabilities = capabilities,
            })

            -- Lua LSP for general Lua files
            vim.lsp.config("lua_ls", {
                cmd = { "lua-language-server" },
                filetypes = { "lua" },
                root_dir = vim.fs.dirname(vim.fs.find({ ".git" }, { upward = true })[1] or vim.loop.cwd()),
                settings = {
                    Lua = {
                        runtime = { version = "LuaJIT", path = vim.split(package.path, ";") },
                        diagnostics = { globals = { "vim" } },
                        workspace = { library = vim.api.nvim_get_runtime_file("", true) },
                        telemetry = { enable = false },
                    },
                },
                capabilities = capabilities,
            })

            local opts = { noremap = true, silent = true }
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

            -- Track current state globally
            local inlay_hints_enabled = true

            -- Enable inlay hints when LSP attaches (default = on)
            vim.api.nvim_create_autocmd("LspAttach", {
                callback = function(args)
                    local client = vim.lsp.get_client_by_id(args.data.client_id)
                    if client and client.server_capabilities.inlayHintProvider then
                        vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
                    end
                end,
            })

            -- Keymap to toggle inlay hints
            vim.keymap.set("n", "<leader>ih", function()
                inlay_hints_enabled = not inlay_hints_enabled
                vim.lsp.inlay_hint.enable(inlay_hints_enabled)
                vim.notify("Inlay hints " .. (inlay_hints_enabled and "enabled" or "disabled"))
            end, { desc = "Toggle inlay hints" })

            -- Pretty diagnostic signs
            local signs = {
                Error = " ",  -- nf-fa-times_circle
                Warn  = " ",  -- nf-fa-exclamation_triangle
                Hint  = " ",  -- nf-fa-info_circle
                Info  = " ",  -- nf-fa-question_circle
            }

            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
            end

            -- Virtual text diagnostics configuration
            vim.diagnostic.config({
                virtual_text = false,
                signs = true,
                underline = true,
                update_in_insert = false,  -- Don't update diagnostics while typing
                severity_sort = true,
                float = {
                    border = "rounded",
                    source = "always",
                    focusable = false,
                    header = "",
                    prefix = "",
                },
            })

            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                callback = function()
                    vim.diagnostic.open_float(nil, { focus = false })
                end,
            })

        end,
    },

    -- Diagnostics UI
    {
        "folke/trouble.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("trouble").setup({})
            vim.keymap.set("n", "<space>a", "<cmd>Trouble diagnostics<cr>", { desc = "Trouble diagnostics" })
        end,
    },
    {
        "nvimdev/lspsaga.nvim",
        event = "LspAttach",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons",
        },
        config = function()
            require("lspsaga").setup({
                ui = {
                    border = "rounded",
                    winblend = 10,
                    devicon = true,
                    title = true,
                },
                hover = {
                    max_width = 0.6,
                },
            })

            vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", { desc = "Pretty hover" })
        end,
    }
}
