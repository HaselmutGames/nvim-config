-- This function gets run when LSP attaches to a particular buffer.
-- That is to say, every time a new file is opened that is associated with
-- an lsp this function will be executed to configure the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function (event)
        -- A function that lets us more easily define mappings specific
        -- for LSP related items. It sets the mode, buffer and description each time.
        local map = function (keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        -- Rename the variable under cursor.
        map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

        -- Execute a code action.
        map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

        -- Find references for word under cursor.
        map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

        -- Jump to implementation of word under cursor.
        map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

        -- Jump to definition of word under cursor.
        -- To jump back, press <C-t>.
        map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

        -- Create a keymap to toggle inlay hints in code,
        -- if the language server that's being used supports them.
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function ()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_disabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
        end
    end,
})
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local util = require('lspconfig.util')
local servers = {
    lua_ls = {
        -- cmd = {...},
        -- filetypes = {...},
        -- capabilities = {},
        settings = {
            Lua = {
                completion = {
                    callSnippet = 'Replace',
                },
                diagnostics = { disable = { 'missing-fields' } },
            },
        },
    },
    omnisharp = {
        cmd = {
            vim.fn.stdpath('data') .. '/mason/packages/omnisharp/OmniSharp',
            '--languageserver',
            '-z',
            '--hostPID',
            tostring(vim.fn.getpid()),
        },
        root_dir = function(fname)
            return util.root_pattern('*.sln', '*.csproj', '.git')(fname)
        end,
        settings = {
            FormattingOptions = { EnableEditorConfigSupport = true },
            Sdk = { IncludePrereleases = true },
        },
    },
}
local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
    'stylua', -- format lua code
})
require('mason-tool-installer').setup { ensure_installed = ensure_installed }

require('mason-lspconfig').setup {
    ensure_installed = {},
    automatic_installation = false,
    handlers = {
        function (server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above.
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
        end,
    },
}

-- Mason setup
-- require('mason').setup()
-- 
-- require('mason-lspconfig').setup({
--     ensure_installed = {
--         'lua_ls', -- Lua language server
--         'omnisharp', -- C# language server
--     },
--     automatic_installation = true
-- })
-- 
-- -- nvim-cmp setup
-- local cmp = require('cmp')
-- cmp.setup({
--     snippet = {
--         expand = function(args)
--             require('luasnip').lsp_expand(args.body)
--         end,
--     },
--     mapping = cmp.mapping.preset.insert({
--         ['<CR>'] = cmp.mapping.confirm({ select = true }),
--         ['<C-Space'] = cmp.mapping.complete(),
--     }),
--     sources = cmp.config.sources({
--         { name = 'nvim_lsp' },
--         { name = 'luasnip' },
--     }, {
--         { name = 'buffer' },
--     }),
-- })
-- 
-- -- Global LSP keybindings
-- -- Function that runs when LSP attaches to a buffer
-- local on_attach = function(_, bufnr)
--     local opts = { buffer = bufnr, silent = true }
--     local map = vim.keymap.set
-- 
--     map('n', 'gd', vim.lsp.buf.definition, opts)
--     map('n', 'K', vim.lsp.buf.hover, opts)
--     map('n', '<leader>rn', vim.lsp.buf.rename, opts)
--     map('n', '<leader>ca', vim.lsp.buf.code_action, opts)
--     map('n', 'gr', vim.lsp.buf.references, opts)
--     map('n', '[d', vim.diagnostic.goto_prev, opts)
--     map('n', ']d', vim.diagnostic.goto_next, opts)
-- end
-- 
-- -- Setup language servers
-- --vim.opt.colorcolumn = "80"
-- local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- local servers = { 'lua_ls', 'omnisharp' }
-- 
-- -- Lua
-- vim.lsp.config('lua_ls', {
--     on_attach = on_attach,
--     capabilities, capabilities,
--     settings = {
--         Lua = {
--             runtime = { version = 'LuaJIT' },
--             diagnostics = { globals = { 'vim' } },
--             workspace = { checkThirdParty = false },
--             telemetry = { enable = false },
--         },
--     },
-- })
-- 
-- -- C# omnisharp
-- do
--     local mason_registry = require('mason-registry')
-- 
--     local ok, omnisharp_pkg = pcall(mason_registry.get_package, 'omnisharp')
--     if not ok or not omnisharp_pkg then
--         vim.notify('Omnisharp not installed via Mason!', vim.log.levels.ERROR)
--         return
--     end
--     local install_path = omnisharp_pkg.path
--         or (omnisharp_pkg.get_install_path and omnisharp_pkg:get_install_path())
--         or (vim.fn.stdpath('data') .. '/mason/packages/omnisharp')
-- 
--     local wrapper_path = install_path .. '/OmniSharp'
--     if vim.fn.executable(wrapper_path) == 0 then
--         vim.notify('Omnisharp wrapper not found at ' .. exe_path, vim.log.levels.ERROR)
--         return
--     end
-- 
--     vim.lsp.config('omnisharp', {
--         on_attach = on_attach,
--         capabilities = capabilities,
--         cmd = { 'dotnet', wrapper_path },
--         enable_editorconfig_support = true,
--         enable_rosyln_analyzers = true,
--         organize_imports_on_format = true,
--         enable_import_completion = true,
--         root_dir = function(fname)
--             local config_util = require('lspconfig.util')
--             return config_util.root_pattern('*.sln', '*.csproj', '.git')(fname)
--         end,
--     })
-- end
-- 
-- vim.lsp.enable({
--     'lua_ls',
--     'omnisharp',
-- })
