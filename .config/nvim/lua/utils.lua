
local function persistent_undo()
    if pcall(function()
        vim.fn.system {
            'mkdir',
            '-p',
            '~/.vim/temp_dirs/undodir'
        }
    end) then
        vim.o.undodir = '~/.vim/temp_dirs/undodir'
        vim.o.undofile = true
    else
        vim.cmd('echo "Could not create undodir"')
    end
end

return { persistent_undo = persistent_undo }
