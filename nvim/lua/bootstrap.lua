-- required packages
local PKGS = {
    "savq/paq-nvim";
    "nvim-lua/plenary.nvim";
    "svermeulen/vimpeccable";
}

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

        vim.cmd('packadd paq-nvim')
        local paq = require('paq')

        paq(pkgs)
        paq.install()
    end
end

return { bootstrap = bootstrap_paq }
