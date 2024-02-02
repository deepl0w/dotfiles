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
    --  list of *all* buffer numbers
    local buffers = vim.api.nvim_list_bufs()
    local next = next

    for i = 1, #buffers do
        local wins = vim.fn.win_findbuf(buffers[i])
        if not next(wins) then
            vim.cmd.bdelete(buffers[i])
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

