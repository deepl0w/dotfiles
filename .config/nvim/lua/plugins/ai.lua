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
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            -- "dyamon/codecompanion-filewise.nvim"
        },
        opts = {
            strategies = {
                chat = {
                    adapter = "copilot",
                    model = "claude-sonnet-4.6",
                },
            },
        },
        init = function()
            require("codecompanion").setup({
                -- extensions = {
                --     custom_instructions = {
                --         enabled = true,
                --         opts = {
                --             simple = {
                --                 '.github/copilot-instructions.md',
                --                 'AGENT.md', 'AGENTS.md', 'CLAUDE.md',
                --             },
                --             conditional = {
                --                 '.github/instructions/*.instructions.md'
                --             },
                --             triggers = {
                --                 user_events = { "CodeCompanionChatCreated", "CodeCompanionChatSubmitted" },
                --                 variable_buffer = false,
                --                 slash_file = true,
                --                 slash_buffer = true,
                --             },
                --             keymaps = {
                --                 sync_context = 'gi',
                --             },
                --             root_markers = { '.git', '.github' },
                --         }
                --     },
                --     custom_prompts = {
                --         enabled = true,
                --         opts = {
                --             prompt_dirs = {
                --                 ".github/prompts",
                --             },
                --             prompt_role = "user",
                --             model_map = {},
                --             tool_map = {},
                --             format_content = function(body)
                --                 return body:gsub('%f[#]#','###')
                --             end,
                --             root_markers = { '.git', '.github' },
                --         }
                --     }
                -- }
            })
            vim.g.codecompanion_auto_tool_mode = true
        end,
    }
}
