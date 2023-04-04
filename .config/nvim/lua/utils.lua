
local utils = {}
local Path = require('plenary.path')

function utils.persistent_undo()
    home = Path:new(Path.path.home)
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

return utils

