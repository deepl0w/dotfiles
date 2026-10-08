local utils = {}
local Path = require('plenary.path')

function utils.persistent_undo()
    local home = Path:new(Path.path.home)
    if pcall(function()
        vim.fn.system {
            'mkdir',
            '-p',
            home .. '/.vim/temp_dirs/undodir'
        }
    end) then
        vim.o.undodir = home .. '/.vim/temp_dirs/undodir'
        vim.o.undofile = true
    else
        vim.cmd('echo "Could not create undodir"')
    end
end

function utils.is_wsl()
    return vim.fn.has("wsl") == 1
end

function utils.wipeout()
    -- Get a list of all buffer numbers
    local buffers = vim.api.nvim_list_bufs()

    -- Get a list of all windows
    local windows = vim.api.nvim_list_wins()

    -- Create a set of buffers that are open in windows or floating windows
    local open_buffers = {}
    for _, win in ipairs(windows) do
        local buf = vim.api.nvim_win_get_buf(win)
        open_buffers[buf] = true
    end

    for _, buf in ipairs(buffers) do
        -- Check if the buffer is loaded, unmodified and not open in any window or floating window
        if vim.api.nvim_buf_is_loaded(buf) and not open_buffers[buf] and not vim.bo[buf].modified then
            -- Delete the buffer; without force, terminals with a running job are kept
            pcall(vim.api.nvim_buf_delete, buf, { force = false })
        end
    end
end

function utils.contains(table, val)
    for i=1,#table do
        if table[i] == val then
            return true
        end
    end
    return false
end

return utils

