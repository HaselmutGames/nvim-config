vim.opt.shell = 'powershell.exe'
vim.opt.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
vim.opt.shellquote = ''
vim.opt.shellxquote = ''

-- File encoding and line endings
vim.opt.fileformat = 'unix'
vim.opt.fileformats = { 'unix', 'dos' }

-- Defaul paths for ripgrep, fzf, etc. if installed by scoop
local function in_path(cmd)
    return vim.fn.executable(cmd) == 1
end

if not in_path('rg') then
    print('ripgrep not found. Install with: scoop install ripgrep')
end

if not in_path('fd') then
    print('fd not found. Install with: scoop install fd')
end

