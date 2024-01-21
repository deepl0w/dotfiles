local function bootstrap_paq(pkgs)
    local path = vim.fn.stdpath('data') .. '/site/pack/paqs/start/paq-nvim'
    if vim.fn.empty(vim.fn.glob(path)) > 0 then
        vim.fn.system {
            'git',
            'clone',
            '--depth=1',
            'https://github.com/savq/paq-nvim.git',
            path
        }
    end
    vim.cmd('packadd paq-nvim')
    return require('paq')(pkgs)
end

return { bootstrap = bootstrap_paq }
