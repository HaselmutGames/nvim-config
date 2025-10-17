vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

--vim.opt.colorcolumn = "80"

vim.g.have_nerd_font = true

-- Set how neovim displays whitespaces in editor
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '.', nbsp = '␣' }

-- if perfoming an operation that would fail due to unsaved changes in the buffer (like ':q'),
-- instead raise a dialog asking if you wish to save the current file(s)
vim.o.confirm = true

vim.g.mapleader = " "
