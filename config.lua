--     __                          _    ___
--    / /   __  ______  ____ _____| |  / (_)___ ___
--   / /   / / / / __ \/ __ `/ ___/ | / / / __ `__ \
--  / /___/ /_/ / / / / /_/ / /   | |/ / / / / / / /
-- /_____/\__,_/_/ /_/\__,_/_/    |___/_/_/ /_/ /_/


-- {{{ autocommands 
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  pattern = { "*.scala", "*.sbt", "*.sc" },
  callback = function() require('user.metals').start() end,
})
--- }}}

-- {{{ options 
vim.opt.timeoutlen = 500
vim.opt.foldmethod = "marker"
vim.opt.relativenumber = true

lvim.log.level = "warn"
lvim.colorscheme = "onedarker"
lvim.transparent_window = true
lvim.format_on_save = false
lvim.lint_on_save = true

lvim.lsp.diagnostics.virtual_text = false
vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "clangd" })
require("lvim.lsp.null-ls.formatters").setup {
  { exe = "black", filetypes = { "python" } },
  { exe = "isort", filetypes = { "python" } },
  { exe = "djlint", filetypes = { "django" } },
  { exe = "scalafmt", filetypes = { "scala" } },
}
require("lvim.lsp.null-ls.linters").setup {
  { exe = "pylint", filetypes = { "python" } },
  { exe = "djlint", filetypes = { "django" } },
  { exe = "cppcheck", filetypes = { "cpp", "c" } },
}
-- }}}

-- {{{ builtin plugins 
lvim.builtin.dap.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.filters.dotfiles = true
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true
lvim.builtin.treesitter.ensure_installed = {
  "bash", "c", "cmake", "cpp", "gitignore", "html", "java",
  "javascript", "latex", "lua", "markdown", "python", "scala"
}
lvim.builtin.which_key.setup.window = { padding = { 0, 0, 0, 0 } }
lvim.builtin.which_key.setup.layout = {
  spacing = 3,
  align = "left",
  height = { min = 1, max = 10 }
}
lvim.builtin.alpha.dashboard.section.header.val = {
  "   ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆          ",
  "    ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦       ",
  "          ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻j⢿⣿⣧⣄     ",
  "           ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄    ",
  "          ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀   ",
  "   ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄  ",
  "  ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄   ",
  " ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄  ",
  " ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄ ",
  "     ⠻⣿⣿⣿⣿⣶  ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟⣤⣾⡿⠃     ",
}
-- }}}

-- {{{ dap 
local mason_path = vim.fn.glob(vim.fn.stdpath "data" .. "/mason/")
local status_ok, dap = pcall(require, "dap")
if not status_ok then return end

dap.adapters.codelldb = {
  type = "server",
  port = "${port}",
  executable = {
    command = mason_path .. "bin/codelldb",
    args = { "--port", "${port}" },
  },
}
dap.configurations.cpp = {
  {
    name = "Launch file",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = true,
  },
}
dap.configurations.c = dap.configurations.cpp
dap.configurations.scala = {
  {
    type = "scala",
    request = "launch",
    name = "Run or Test Target",
    metals = { runType = "runOrTestFile" },
  },
  {
    type = "scala",
    request = "launch",
    name = "Test Target",
    metals = { runType = "testTarget" },
  },
}

pcall(function() require("dap-python").setup(mason_path .. "packages/debugpy/venv/bin/python") end)
pcall(function() require("dap-python").test_runner = "pytest" end)
-- }}}

-- {{{ additional plugins 
lvim.plugins = {
  "nvim-neotest/neotest",
  "scalameta/nvim-metals",
  "mfussenegger/nvim-dap-python",
  {
    "zbirenbaum/copilot.lua",
    event = { "VimEnter" },
    config = function()
      vim.defer_fn(function()
        require("copilot").setup {
          plugin_manager_path = get_runtime_dir() .. "/site/pack/packer",
        }
      end, 100)
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    after = { "copilot.lua", "nvim-cmp" },
  },
  {
    "Pocco81/auto-save.nvim",
    config = function()
      require("user.autosave").config()
    end,
  },
  {
    "lervag/vimtex",
    config = function()
      require("user.vimtex").config()
    end,
  },

  {
    "nvim-pack/nvim-spectre",
    event = "BufRead",
    config = function()
      require("user.spectre").config()
    end
  },
  {
    "folke/persistence.nvim",
    event = "VimEnter",
    module = "persistence",
    config = function()
      require("persistence").setup {
        dir = vim.fn.expand(vim.fn.stdpath "config" .. "/session/"),
        options = { "buffers", "curdir", "tabpages", "winsize" }
      }
    end,
  },
  {
    "tzachar/cmp-tabnine",
    config = function()
      local tabnine = require "cmp_tabnine.config"
      tabnine:setup {
        max_lines = 1000,
        max_num_results = 20,
        sort = true,
      }
    end,
    run = "./install.sh",
    requires = "hrsh7th/nvim-cmp"
  },
  {
    "karb94/neoscroll.nvim",
    event = "BufRead",
    config = function()
      require("neoscroll").setup {
        mappings = { "<C-u>", "<C-d>", "<C-f>", "<C-b>", "zt", "zz", "zb" },
        hide_cursor = true,
        stop_eof = true,
        use_local_scrolloff = false,
        respect_scrolloff = false,
        cursor_scrolls_alone = false,
        easing_function = nil,
      }
    end
  },
}
-- }}}
