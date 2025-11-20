-- This function gets run when LSP attaches to a particular buffer.
-- That is to say, every time a new file is opened that is associated with
-- an lsp this function will be executed to configure the current buffer
local lspconfig = require("lspconfig")
local util = require("lspconfig.util")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
	callback = function(event)
		-- A function that lets us more easily define mappings specific
		-- for LSP related items. It sets the mode, buffer and description each time.
		local map = function(keys, func, desc, mode)
			mode = mode or "n"
			vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
		end

		-- Rename the variable under cursor.
		map("grn", vim.lsp.buf.rename, "[R]e[n]ame")

		-- Execute a code action.
		map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

		-- Find references for word under cursor.
		map("grr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")

		-- Jump to implementation of word under cursor.
		map("gri", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")

		-- Jump to definition of word under cursor.
		-- To jump back, press <C-t>.
		map("grd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")

		map("hd", vim.lsp.buf.hover, "[H]over [D]ocumentation")

		-- Format file
		map("<leader>ff", vim.lsp.buf.format, "[F]ormat [F]ile")

		-- Create a keymap to toggle inlay hints in code,
		-- if the language server that's being used supports them.
		local client = vim.lsp.get_client_by_id(event.data.client_id)
		if client and vim.lsp.inlay_hint then
			map("<leader>th", function()
				local ih = vim.lsp.inlay_hint
				local enabled = ih.is_enabled and ih.is_enabled({ bufnr = event.buf })
				ih.enable(not enabled, { bufnr = event.buf })
			end, "[T]oggle Inlay [H]ints")
		end
	end,
})
-- =======================================
-- Path setup for JDTLS
-- =======================================
local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
-- Detect Platform
local system = vim.loop.os_uname().sysname
local java_config
if system:find("Windows") then
	java_config = jdtls_path .. "/config_win"
elseif system:find("Darwin") then
	java_config = jdtls_path .. "/config_mac"
else
	java_config = jdtls_path .. "/config_linux"
end
local java_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")

-- Workspace per project
local function jdtls_workspace()
	local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
	return vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name
end

-- Detect Java project types
local jdtls_root = util.root_pattern("pom.xml", "build.gradle", "settings.gradle", ".git")
local java_ls_root = function(fname)
	-- Only start java-language-server if JDTLS root does not match
	if not jdtls_root(fname) then
		return util.root_pattern(".git", "*.java")(fname)
	end
end
-- =======================================
-- Path setup for omnisharp C#
-- =======================================
local omnisharp_path
if vim.fn.has("win32") == 1 then
	omnisharp_path = vim.fn.expand("%LOCALAPPDATA%/nvim-data/mason/packages/omnisharp/OmniSharp")
else
	omnisharp_path = vim.fn.expand("~/.local/share/nvim/mason/packages/omnisharp/OmniSharp")
end
-- =======================================
-- LSP server definitions
-- =======================================
local servers = {
	-- Lua
	lua_ls = {
		-- cmd = {...},
		-- filetypes = {...},
		-- capabilities = {},
		settings = {
			Lua = {
				completion = {
					callSnippet = "Replace",
				},
				diagnostics = { globals = { "vim" }, disable = { "missing-fields" } },
			},
		},
	},

	-- C# - OmniSharp
	omnisharp = {
		cmd = {
			omnisharp_path,
			"--languageserver",
			"--hostPID",
			tostring(vim.fn.getpid()),
		},
		root_dir = function(fname)
			return util.root_pattern("*.sln", "*.csproj", "*.slnx", ".git")(fname)
		end,
		settings = {
			FormattingOptions = { EnableEditorConfigSupport = true },
			Sdk = { IncludePrereleases = true },
		},
	},

	-- Java - JDTLS (Maven + Gradle)
	jdtls = {
		cmd = {
			"java",
			"-Declipse.application=org.eclipse.jdt.ls.core.id1",
			"-Dosgi.bundles.defaultStartLevel=4",
			"-Declipse.product=org.eclipse.jdt.ls.core.product",
			"-Dlog.protocol=true",
			"-Dlog.level=ALL",
			"-Xmx1g",
			"--add-modules=ALL-SYSTEM",
			"--add-opens",
			"java.base/java.util=ALL-UNNAMED",
			"--add-opens",
			"java.base/java.lang=ALL-UNNAMED",
			"-jar",
			java_jar,
			"-configuration",
			java_config,
			"-data",
			jdtls_workspace(),
		},
		root_dir = jdtls_root,
		capabilities = capabilities,
		settings = {
			java = {
				format = {
					enabled = true,
					settings = {
						url = vim.fn.stdpath("data") .. "/mason/packages/google-java-format/google-java-format.xml",
						profile = "GoogleStyle",
					},
				},
				signatureHelp = { enabled = true },
				contentProvider = { preferred = "fernflower" },
				completion = {
					favoriteStaticMembers = {
						"org.junit.Assert.*",
						"org.junit.Assume.*",
						"org.junit.jupiter.api.Assertions.*",
						"org.junit.jupiter.api.Assumptions.*",
						"org.junit.jupiter.api.DynamicContainer.*",
						"org.junit.jupiter.api.DynamicTest.*",
					},
					filteredTypes = { "java.awt.*", "com.sun.*" },
				},
			},
		},
		init_options = {
			bundles = {},
		},
	},

	-- Java (Simple projects) - georgewfraser/java-language-server
	java_language_server = {
		cmd = { vim.fn.expand("~/.local/share/nvim/mason/packages/java-language-server/java-language-server") },
		root_dir = java_ls_root,
		capabilities = capabilities,
		settings = {
			java = {
				format = {
					enabled = true,
					settings = {
						url = vim.fn.stdpath("data") .. "/mason/packages/google-java-format/google-java-format.xml",
						profile = "GoogleStyle",
					},
				},
				signatureHelp = { enabled = true },
				contentProvider = { preferred = "fernflower" },
				completion = {
					favoriteStaticMembers = {
						"org.junit.Assert.*",
						"org.junit.Assume.*",
						"org.junit.jupiter.api.Assertions.*",
						"org.junit.jupiter.api.Assumptions.*",
						"org.junit.jupiter.api.DynamicContainer.*",
						"org.junit.jupiter.api.DynamicTest.*",
					},
					filteredTypes = { "java.awt.*", "com.sun.*" },
				},
			},
		},
		init_options = {
			bundles = {},
		},
	},
}

-- =======================================
-- Setup servers through Mason
-- =======================================
local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
	"stylua", -- format lua code
})
require("mason").setup()
require("mason-lspconfig").setup({
	automatic_installation = false,
	handlers = {
		function(server_name)
			local server = servers[server_name] or {}
			server.capabilities = capabilities
			lspconfig[server_name].setup(server)
		end,
	},
})

require("mason-tool-installer").setup({ ensure_installed = ensure_installed })
