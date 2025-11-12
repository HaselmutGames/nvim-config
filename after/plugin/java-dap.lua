-- This should hook jdtls into DAP (nvim-dap) adn JUnit test runner.
-- Debug or run tests directly from Neovim with commands like:
-- :lua require'jdtls'.test_nearest_method()
-- :lua require'jdtls'.test_class()
-- :lua require'jdtls'.pick_test()
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  callback = function()
    local ok, jdtls = pcall(require, 'jdtls')
    if not ok then
      vim.notify('jdtls not found (Java LSP)', vim.log.levels.WARN)
      return
    end

    local home = os.getenv('HOME')
    local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
    local workspace_dir = home .. '/.local/share/eclipse/' .. project_name

    jdtls.start_or_attach({
      cmd = {
        vim.fn.stdpath('data') .. '/mason/bin/jdtls',
        '-data', workspace_dir,
      },
      root_dir = jdtls.setup.find_root({ 'pom.xml', 'gradlew', '.git', 'mvnw' }),
      settings = {
        java = {
          signatureHelp = { enabled = true },
          completion = { favoriteStaticMembers = { 'org.hamcrest.MatcherAssert.assertThat', 'org.hamcrest.Matchers.*' } },
        },
      },
    })
  end,
})
