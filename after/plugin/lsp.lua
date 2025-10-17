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
local omnisharp_path
if vim.fn.has('win32') == 1 then
    omnisharp_path = vim.fn.expand('%LOCALAPPDATA%/nvim-data/mason/packages/omnisharp/OmniSharp')
else
    omnisharp_path = vim.fn.expand('~/.local/share/nvim/mason/packages/omnisharp/OmniSharp')
end
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
            omnisharp_path,
            '--languageserver',
            '--hostPID',
            tostring(vim.fn.getpid()),
        },
        root_dir = function(fname)
            return util.root_pattern('*.sln', '*.csproj', '*.slnx', '.git')(fname)
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
