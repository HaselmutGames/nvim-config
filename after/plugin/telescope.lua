local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'Telescope find in [P]roject [f]iles' })
vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'Telescope find in a git repo' })
vim.keymap.set('n', '<leader>ps', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fs', function()
	builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
-- Shortcut for searching Neovim configuration files
vim.keymap.set('n', '<leader>sn', function()
    builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })

-- Show all workspace diagnostics
vim.keymap.set('n', '<leader>lw', builtin.diagnostics, { desc = '[L]ist [W]orkspace Diagnostics' })

-- Show only diagnostics for current buffer
vim.keymap.set('n', '<leader>lb', function()
    builtin.diagnostics({ bufnr = 0 })
end, { desc = '[L]ist [B]uffer Diagnostics' })
