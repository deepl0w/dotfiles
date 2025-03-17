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

function utils.read_file(path)
    local f = assert(io.open(path, 'rb'))
    local content = f:read('*all')
    f:close()
    return content
end

function utils.is_wsl()
    if vim.fn.has("unix") then
        local lines = utils.read_file("/proc/version")
        if lines[0] == "Microsoft" then
            return true
        end
    end
  return false
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
        -- Check if the buffer is loaded and not open in any window or floating window
        if vim.api.nvim_buf_is_loaded(buf) and not open_buffers[buf] then
            -- Delete the buffer
            vim.api.nvim_buf_delete(buf, { force = true })
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

function utils.show_documentation()
    if utils.contains({'vim', 'help'}, vim.bo.filetype) then
        local cword = vim.fn.expand('<cword>')
        vim.cmd("execute 'h " .. cword .. "'")
    else
        vim.cmd("call CocAction('doHover')")
    end
end

function utils.check_backspace()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

return utils

