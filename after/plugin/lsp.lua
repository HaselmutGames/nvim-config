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

for _, server_name in ipairs(servers) do
    if server_name == 'lua_ls' then
        vim.lsp.config['lua_ls'] = {
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
                Lua = {
                    runtime = { version = 'LuaJIT' },
                    diagnostics = { globals = { 'vim' } },
                    workspace = { checkThirdParty = false },
                    telemetry = { enable = false },
                },
            },
        }
    elseif server_name == 'omnisharp' then
        vim.lsp.config['omnisharp'] = {
            on_attach = on_attach,
            capabilities = capabilities,
            cmd = { 'omnisharp' }, -- mason installs this
            enable_editorconfig_support = true,
            enable_roslyn_analyzers = true,
            organize_imports_on_format = true,
            enable_import_completion = true,
            root_dir = function(fname)
                return lspconfig.util.root_pattern('*.sln', '*.csproj', '.git')(fname)
            end,
        }
    end
end
