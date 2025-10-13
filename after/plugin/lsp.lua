-- Mason setup
require('mason').setup()

require('mason-lspconfig').setup({
    ensure_installed = {
        'lua_ls', -- Lua language server
        'omnisharp', -- C# language server
    },
    automatic_installation = true
})

-- nvim-cmp setup
local cmp = require('cmp')
cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space'] = cmp.mapping.complete(),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    }, {
        { name = 'buffer' },
    }),
})

-- Global LSP keybindings
-- Function that runs when LSP attaches to a buffer
local on_attach = function(_, bufnr)
    local opts = { buffer = bufnr, silent = true }
    local map = vim.keymap.set

    map('n', 'gd', vim.lsp.buf.definition, opts)
    map('n', 'K', vim.lsp.buf.hover, opts)
    map('n', '<leader>rn', vim.lsp.buf.rename, opts)
    map('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    map('n', 'gr', vim.lsp.buf.references, opts)
    map('n', '[d', vim.diagnostic.goto_prev, opts)
    map('n', ']d', vim.diagnostic.goto_next, opts)
end

-- Setup language servers
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local servers = { 'lua_ls', 'omnisharp' }

-- Lua
vim.lsp.config('lua_ls', {
    on_attach = on_attach,
    capabilities, capabilities,
    settings = {
        Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim' } },
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    },
})

-- C# omnisharp
do
    local mason_registry = require('mason-registry')

    local ok, omnisharp_pkg = pcall(mason_registry.get_package, 'omnisharp')
    if not ok or not omnisharp_pkg then
        vim.notify('Omnisharp not installed via Mason!', vim.log.levels.ERROR)
        return
    end
    local install_path = omnisharp_pkg.path
        or (omnisharp_pkg.get_install_path and omnisharp_pkg:get_install_path())
        or (vim.fn.stdpath('data') .. '/mason/packages/omnisharp')

    local wrapper_path = install_path .. '/OmniSharp'
    if vim.fn.executable(wrapper_path) == 0 then
        vim.notify('Omnisharp wrapper not found at ' .. exe_path, vim.log.levels.ERROR)
        return
    end

    vim.lsp.config('omnisharp', {
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = { 'dotnet', wrapper_path },
        enable_editorconfig_support = true,
        enable_rosyln_analyzers = true,
        organize_imports_on_format = true,
        enable_import_completion = true,
        root_dir = function(fname)
            local config_util = require('lspconfig.util')
            return config_util.root_pattern('*.sln', '*.csproj', '.git')(fname)
        end,
    })
end

vim.lsp.enable({
    'lua_ls',
    'omnisharp',
})
