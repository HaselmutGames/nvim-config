-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.8',
        -- or                            , branch = '0.1.x',
        requires = { {'nvim-lua/plenary.nvim'} }
    }
    use({
        'rose-pine/neovim',
        as = 'rose-pine',
        config = function()
            vim.cmd('colorscheme rose-pine-moon')
        end
    })
    use{'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons'}
}
use({'nvim-treesitter/nvim-treesitter', run = function ()
    pcall(vim.cmd, 'TSUpdate')
end})
use('nvim-treesitter/playground')
use('theprimeagen/harpoon')
use('mbbill/undotree')
use('tpope/vim-fugitive')
-- Plugin to show pending keybinds
use({
    'folke/which-key.nvim',
    event = 'VimEnter',
    config = function ()
        require('which-key').setup({
            delay = 0,
            icons = {
                mappings = vim.g.have_nerd_font,
                keys = vim.g.have_nerd_font and {},
            },
            -- Document existing key chains
            spec = {
                { '<leader>s', group = '[S]earch' },
                { '<leader>t', group = '[T]oggle' },
                { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
            },
        })
    end,
})

-- LSP plugins
use({
    -- 'lazydev configures Lua LSP for Neovim config, runtime and plugins
    -- used for completion, annotations, and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
        library = {
            -- Load luvit types when the 'vim.uv' word is found
            { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
        },
    },
})
-- Main LSP configuration
use ({
    'neovim/nvim-lspconfig',             -- core LSP client configurations
    requires = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        'j-hui/fidget.nvim',
    },
    config = function()
        require('mason').setup()
        require('mason-lspconfig').setup()
    end,
})
use({
    'hrsh7th/nvim-cmp',
    requires = {
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
        'L3MON4D3/LuaSnip',
    },
    config = function()
        local cmp = require('cmp')
        cmp.setup({
            mapping = cmp.mapping.preset.insert({
                ['<CR>'] = cmp.mapping.confirm({ select = true }),
            }),
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
            }, {
                { name = 'buffer' },
            }),
        })
    end,
})
end)
