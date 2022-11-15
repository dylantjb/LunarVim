local M = {}

M.start = function()
  local status_ok, metals = pcall(require, "metals")
  if not status_ok then return end
  local metals_config = metals.bare_config()
  lvim.builtin.telescope.on_config_done = function(telescope)
    pcall(telescope.load_extension, "metals")
  end
  metals_config.on_attach = function(client, bufnr)
    metals.setup_dap()
    require("lvim.lsp").common_on_attach(client, bufnr)
    require("which-key").register(
      { ["gO"] = { "<cmd>lua require('metals').organize_imports()<CR>", "Organize Imports" } },
      { mode = "n", buffer = bufnr }
    )
  end
  metals_config.settings = {
    showImplicitArguments = true,
    showInferredType = true,
  }
  metals_config.init_options.statusBarProvider = "on"
  metals_config.capabilities = require("lvim.lsp").common_capabilities()
  metals.initialize_or_attach(metals_config)
end

return M
