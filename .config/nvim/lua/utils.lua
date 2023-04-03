
local utils = {}
local Path = require('plenary.path')

function utils.persistent_undo()
    if pcall(function()
        vim.fn.system {
            'mkdir',
            '-p',
            '~/.vim/temp_dirs/undodir'
        }
    end) then
        home = Path:new(Path.path.home)
        vim.o.undodir = home .. '/.vim/temp_dirs/undodir'
        vim.o.undofile = true
    else
        vim.cmd('echo "Could not create undodir"')
    end
end

return utils

