local function bootstrap_paq(pkgs)
    local path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(path) then
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable", -- latest stable release
            path,
        })
    end
    vim.opt.rtp:prepend(path)
    return require('lazy').setup(pkgs)
end

return { bootstrap = bootstrap_paq }
