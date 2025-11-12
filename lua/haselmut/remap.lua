vim.g.mapleader =(' ')
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex)

-- Move selected lines up and down in V-Mode
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv")

-- Paste without loosing paste buffer
vim.keymap.set('x', '<leader>p', '\"_dp')

vim.keymap.set('n', '<leader>y', '\"+y')
vim.keymap.set('v', '<leader>y', '\"+y')
vim.keymap.set('n', '<leader>Y', '\"+Y')

-- split navigation
vim.keymap.set('n', '<leader>wl', '<C-W>h', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<leader>wr', '<C-W>l', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<leader>wd', '<C-W>j', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<leader>wu', '<C-W>k', { desc = 'Move focus to the upper window' })
