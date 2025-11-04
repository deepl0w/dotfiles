-- Don't load AI/Copilot plugins when running inside VSCode
if vim.g.vscode then
    return {}
end

return {
    -- Copilot Lua plugin (core)
    {
        "zbirenbaum/copilot.lua",
        requires = {
            "copilotlsp-nvim/copilot-lsp",
        },
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("copilot").setup({
                suggestion = {
                    auto_trigger = true
                }, nes = {
                    enabled = false,
                    keymap = {
                        accept_and_goto = "<leader>l",
                        accept = false,
                        dismiss = "<Esc>",
                    },
                },
            })
        end,
    },
    -- Copilot LSP (experimental AI code actions)
    {
        "copilotlsp-nvim/copilot-lsp",
        init = function()
            vim.g.copilot_nes_debounce = 500
            vim.lsp.enable("copilot_ls")
            vim.keymap.set("n", "<tab>", function()
                local bufnr = vim.api.nvim_get_current_buf()
                local state = vim.b[bufnr].nes_state
                if state then
                    -- Try to jump to the start of the suggestion edit.
                    -- If already at the start, then apply the pending suggestion and jump to the end of the edit.
                    local _ = require("copilot-lsp.nes").walk_cursor_start_edit()
                    or (
                        require("copilot-lsp.nes").apply_pending_nes()
                        and require("copilot-lsp.nes").walk_cursor_end_edit()
                    )
                    return nil
                else
                    -- Resolving the terminal's inability to distinguish between `TAB` and `<C-i>` in normal mode
                    return "<C-i>"
                end
            end, { desc = "Accept Copilot NES suggestion", expr = true })
        end,
    },
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
            { "zbirenbaum/copilot.lua" }, -- or zbirenbaum/copilot.lua
            { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
        },
        build = "make tiktoken", -- Only on MacOS or Linux
        opts = {
            chat_autocomplete = true,
            sticky = {
                '#filenames:`**/*.cpp`',
                '#filenames:`**/*.h`'
            }
        },
        -- See Commands section for default commands if you want to lazy load on them
    },
    {
        "olimorris/codecompanion.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter", },
        opts = {
            strategies = {
                chat = {
                    adapter = "copilot",
                    model = "claude-sonnet-4.5",
                },
            }
        },
        init = function()
            require("fidget-spinner").init()
        end,
    },
    {
        "j-hui/fidget.nvim",
        opts = {
            -- options
        },
    },
}
