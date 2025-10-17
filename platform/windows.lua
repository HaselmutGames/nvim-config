vim.opt.shell = 'pwsh.exe'
vim.opt.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
vim.opt.shellquote = ''
vim.opt.shellxquote = ''

vim.opt.clipboard:append('unnamedplus')

-- File encoding and line endings
vim.opt.fileformat = 'unix'
vim.opt.fileformats = { 'unix', 'dos' }

-- Create undo dir if missing
local undodir = vim.fn.stdpath('data') .. '/undo'
if vim.fn.isdirectory(undodir) == 0 then
    vim.fn.mkdir(undodir, 'p')
end
vim.opt.undodir = undodir
vim.opt.undofile = true

-- Defaul paths for ripgrep, fzf, etc. if installed by scoop
local function check(cmd, hint)
    if vim.fn.executable(cmd) == 0 then
        vim.notify(('Missing: %s (%s)'):format(cmd, hint), vim.log.levels.WARN)
    end
end

check('rg', 'ripgrep: scoop install ripgrep')
check('fd', 'fd: scoop install fd')
